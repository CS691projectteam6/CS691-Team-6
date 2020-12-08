Use warematic_db;


DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cleanOrder_BeforeUpdate`(
	IN	Order_ID	INT
)
BEGIN

	DELETE	T_Goods_User
	FROM	T_Goods_User
			INNER JOIN T_Order_Goods OG
			ON T_Goods_User.SKU = OG.SKU
	WHERE
			OG.ID_Order = Order_ID;
			
	DELETE
	FROM	T_Order_Goods
	WHERE	ID_Order = Order_ID;
    
    COMMIT;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_OrderByUser`(
	IN Order_ID	INT(11)
)
BEGIN
	UPDATE	T_Orders
			SET Order_Active = 0
	WHERE	ID_Order = Order_ID;
	
    
    UPDATE	T_Order_Goods
			SET Quantity_Order = 0
	WHERE	ID_Order = Order_ID;	
    
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getCount_Orders_toProcess`(
	IN ORDER_TYPE	INT,
    IN USER_TYPE	INT
)
BEGIN

	IF USER_TYPE = 2 THEN
	
		SELECT	COUNT(*) as OrdersToProcess 
		FROM 	T_Orders 
		WHERE	
				ID_Order_Type = ORDER_TYPE
                AND Order_Active = 1
				AND (ID_Order_Status = 1 OR ID_Order_Status = 3);
                
	ELSEIF USER_TYPE = 3 THEN
		
        IF ORDER_TYPE = 1 THEN
			SELECT	COUNT(*) as OrdersToProcess 
			FROM 	T_Orders 
			WHERE	
					ID_Order_Type = ORDER_TYPE
                    AND Order_Active = 1
					AND (ID_Order_Status = 2);
        ELSE
			SELECT	COUNT(*) as OrdersToProcess 
			FROM 	T_Orders 
			WHERE	
					ID_Order_Type = ORDER_TYPE
                    AND Order_Active = 1
					AND (ID_Order_Status = 2 OR ID_Order_Status = 3);
        END IF;
	ELSE
		SELECT	COUNT(*) as OrdersToProcess 
		FROM 	T_Orders 
		WHERE	
				ID_Order_Type = 99;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_Client_HistoryOrders`(
	IN USER_ID		INT,
    IN ORDER_ID		INT,
    IN ORDER_TYPE	INT,
    IN ORDER_STATUS	INT,
    IN INI_DATE		DATE,
    IN END_DATE		DATE
)
BEGIN
	/*
	SELECT 
    
			O.ID_Order,
			O.ID_Order_Type,
			OT.Desc_Type,
            CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
			O.ID_Order_Status,
			S.Description as Order_Status
	FROM
			T_Orders O
			INNER JOIN T_Order_Type OT
			ON O.ID_Order_Type = OT.ID_Order_Type
			INNER JOIN T_Order_Status S
			ON O.ID_Order_Status = S.ID_Order_Status
	WHERE
			O.ID_User = USER_ID
            AND (O.ID_Order_Status = 4 OR O.ID_Order_Status = 5)
	UNION
	SELECT 
    
			O.ID_Order,
			O.ID_Order_Type,
			OT.Desc_Type,
            CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
			O.ID_Order_Status,
			'Deleted' as Order_Status
	FROM
			T_Orders O
			INNER JOIN T_Order_Type OT
			ON O.ID_Order_Type = OT.ID_Order_Type
			INNER JOIN T_Order_Status S
			ON O.ID_Order_Status = S.ID_Order_Status
	WHERE
			O.ID_User = USER_ID
            AND (O.Order_Active = 0);
	*/
    SET @c1 = '';
    SET @c2 = '';
    SET @c3 = '';
    SET @c4 = '';
    SET @c5 = '';
    
    SET @select_ = 'SELECT  * '; 
    SET @from_   = 'FROM ';
    SET @view_   = 'v_completed_orders ';
    SET @where_  = 'WHERE ';
    SET @c1 = 'ID_User = ';
    SET @c1 = CONCAT(@c1, USER_ID, ' ');
    
    SET @order_ = 'ORDER BY Order_Date';
    
    IF (ORDER_ID != '') THEN
		SET @search1 = 'AND ID_Order = ';
        SET @search1 = CONCAT(@search1, ORDER_ID, ' ');
		SET @c2 = CONCAT(@c2, @search1, ' ');
    END IF;
    
    IF (ORDER_TYPE != '') THEN
		SET @search2 = 'AND ID_Order_Type = ';
        SET @search2 = CONCAT(@search2, ORDER_TYPE, ' ');
		SET @c3 = CONCAT(@c3, @search2, ' ');
    END IF;
    
    IF (ORDER_STATUS != '' AND (ORDER_STATUS = 4 OR ORDER_STATUS = 5) ) THEN
		SET @search3 = 'AND ID_Order_Status = ';
        SET @search3 = CONCAT(@search3, ORDER_STATUS, ' ');
		SET @c4 = CONCAT(@c4, @search3, ' ');
	ELSEIF (ORDER_STATUS != '' AND ORDER_STATUS = 6) THEN
		SET @search3 = 'AND ORDER_ACTIVE = 0';
		SET @c4 = CONCAT(@c4, @search3, ' ');
    END IF;
    
    IF (INI_DATE != '' AND END_DATE != '') THEN
		SET @search4 = 'AND Order_Date BETWEEN ';
        SET @search4 = CONCAT(@search4, '''', INI_DATE, '''', ' AND ', '''',END_DATE, '''' ,' ');
		SET @c5 = CONCAT(@c5, @search4, ' ');
    END IF;
    
    SET @Query = CONCAT(@select_);
	SET @Query = CONCAT(@Query, @from_);
	SET @Query = CONCAT(@Query, @view_);
	SET @Query = CONCAT(@Query, @where_);
	SET @Query = CONCAT(@Query, @c1, @c2, @c3, @c4, @c5);
    SET @Query = CONCAT(@Query, @order_);
    
    -- SELECT @Query;
    
	PREPARE stmt from @Query;
	EXECUTE stmt;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_Client_Orders`(
	IN USER_ID		INT,
    IN ORDER_ID		INT,
    IN ORDER_TYPE	INT,
    IN ORDER_STATUS	INT,
    IN INI_DATE		DATE,
    IN END_DATE		DATE
)
BEGIN
	/*SELECT 
			O.ID_Order,
			O.ID_Order_Type,
			OT.Desc_Type,
            CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
			O.ID_Order_Status,
			S.Description as Order_Status
	FROM
			T_Orders O
			INNER JOIN T_Order_Type OT
			ON O.ID_Order_Type = OT.ID_Order_Type
			INNER JOIN T_Order_Status S
			ON O.ID_Order_Status = S.ID_Order_Status
	WHERE
			ID_User = USER_ID
            AND (O.ID_Order_Status <> 4 AND O.ID_Order_Status <> 5)
			AND Order_Active = 1;*/
	
	SET @select_ = 'SELECT ';
	SET @fields1 = 'O.ID_Order, O.ID_Order_Type, OT.Desc_Type, CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date, ';
	SET @fields2 = 'O.ID_Order_Status, S.Description as Order_Status ';
	SET @from_  = 'FROM ';
	SET @table_ = 'T_Orders O ';
	SET @j1 = 'INNER JOIN T_Order_Type OT ';
	SET @j2 = 'ON O.ID_Order_Type = OT.ID_Order_Type ';
	SET @j3 = 'INNER JOIN T_Order_Status S ';
	SET @j4 = 'ON O.ID_Order_Status = S.ID_Order_Status ';
	SET @where_ = 'WHERE ';
	SET @c1 = 'ID_User = ';
    SET @c1 = CONCAT(@c1, USER_ID, ' ');
	SET @c2 = 'AND (O.ID_Order_Status <> 4 AND O.ID_Order_Status <> 5) ';
	SET @c3 = 'AND Order_Active = 1 ';
    
    IF (ORDER_ID != '') THEN
		SET @search1 = 'AND O.ID_Order = ';
        SET @search1 = CONCAT(@search1, ORDER_ID, ' ');
		SET @c3 = CONCAT(@c3, @search1, ' ');
    END IF;
    
    IF (ORDER_TYPE != '') THEN
		SET @search2 = 'AND O.ID_Order_Type = ';
        SET @search2 = CONCAT(@search2, ORDER_TYPE, ' ');
		SET @c3 = CONCAT(@c3, @search2, ' ');
    END IF;
    
    IF (ORDER_STATUS != '') THEN
		SET @search3 = 'AND O.ID_Order_Status = ';
        SET @search3 = CONCAT(@search3, ORDER_STATUS, ' ');
		SET @c3 = CONCAT(@c3, @search3, ' ');
    END IF;
    
    IF (INI_DATE != '' AND END_DATE != '') THEN
		SET @search4 = 'AND O.Order_Date BETWEEN ';
        SET @search4 = CONCAT(@search4, '''', INI_DATE, '''', ' AND ', '''',END_DATE, '''' ,' ');
		SET @c3 = CONCAT(@c3, @search4, ' ');
    END IF;

	-- SET @Query = CONCAT(@select_, @fields1, @fields2, @from_, @table_, @j1, @j2, @j3, @j4, @where_, @c1, @c2, @c3);
	SET @Query = CONCAT(@select_, @fields1, @fields2);
	SET @Query = CONCAT(@Query, @from_);
	SET @Query = CONCAT(@Query, @table_);
	SET @Query = CONCAT(@Query, @j1, @j2, @j3, @j4);
	SET @Query = CONCAT(@Query, @where_);
	SET @Query = CONCAT(@Query, @c1, @c2, @c3);
    
    -- SELECT @Query;
    
	PREPARE stmt from @Query;
	EXECUTE stmt;
    
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_DeliveryOrders_toProcess`(
	IN USER_TYPE INT
)
BEGIN
	IF USER_TYPE = 2 THEN
		SELECT	
				O.ID_Order,
				CONCAT(U.User_FirstName, " ", U.User_LastName) as 	Client_Name,
				U.User_Name as Client_Email,
				CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
				CONCAT(MONTH(O.Delivery_Date), "-", DAY(O.Delivery_Date), "-", YEAR(O.Delivery_Date)) as Delivery_Date,
				S.Description as Order_Status        
		FROM 	
				T_Orders O
				INNER JOIN T_Users U
				ON O.ID_User = U.ID_User
				INNER JOIN T_Order_Status S
				ON O.ID_Order_Status = S.ID_Order_Status
		WHERE	
				O.ID_Order_Type = 2
                AND O.Order_Active = 1
				AND (O.ID_Order_Status = 1)
		ORDER BY O.PickUp_Date;
	
    ELSEIF USER_TYPE = 3 THEN
		SELECT	
				O.ID_Order,
				CONCAT(U.User_FirstName, " ", U.User_LastName) as 	Client_Name,
				U.User_Name as Client_Email,
				CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
				CONCAT(MONTH(O.Delivery_Date), "-", DAY(O.Delivery_Date), "-", YEAR(O.Delivery_Date)) as Delivery_Date,
				S.Description as Order_Status        
		FROM 	
				T_Orders O
				INNER JOIN T_Users U
				ON O.ID_User = U.ID_User
				INNER JOIN T_Order_Status S
				ON O.ID_Order_Status = S.ID_Order_Status
		WHERE	
				O.ID_Order_Type = 2
                AND O.Order_Active = 1
				AND (O.ID_Order_Status = 2 OR O.ID_Order_Status = 3)
		ORDER BY O.PickUp_Date;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_OrderGoods`(
	IN ORDER_ID	INT
)
BEGIN
	SELECT 
			O.ID_Order,
			O.SKU,
			GU.Good_Description as Good_Desc,
			GU.ID_Good_Unit,
			U.Unit_Description as Unit_Desc,
			O.Quantity_Order as Quan_Order
	FROM	
			T_Order_Goods O
			INNER JOIN T_Goods_User GU
			ON O.SKU = GU.SKU
			INNER JOIN T_Goods_Units U
			ON GU.ID_Good_Unit = U.ID_Good_Unit
	WHERE
			O.ID_Order = ORDER_ID;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_OrderGoods_toPickUP`(
	IN ORDER_ID INT
)
BEGIN

	SELECT
			GU.SKU,
			GU.Good_Description,
			U.Unit_Description,
			GU.Available_Quantity as PickUp_Quant
	FROM
			T_Goods_User GU
			INNER JOIN T_Order_Goods OG
			ON GU.SKU = OG.SKU
			INNER JOIN T_Goods_Units U
			ON GU.ID_Good_Unit = U.ID_Good_Unit
	WHERE
			OG.ID_Order = ORDER_ID;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_OrderGoods_to_Delivery`(
	IN	ORDER_ID INT
)
BEGIN
	SELECT
			OG.SKU,
			GU.Good_Description as GOOD_DESC,
			B.Description as BIN_DESC,
			CONCAT(R.Description, " ", S.Description) as SLOT_DESC,
			U.Unit_Description as UNIT_DESC,
			OG.Quantity_Order as QUANT_DELIVER
	FROM	
			T_Order_Goods OG
			INNER JOIN T_Goods_User GU
			ON OG.SKU = GU.SKU
			INNER JOIN T_Goods_Units U
			ON GU.ID_Good_Unit = U.ID_Good_Unit
			INNER JOIN T_Bins B 
			ON GU.ID_Bin = B.ID_Bin
			INNER JOIN T_Location_Slots S
			ON GU.ID_Slot = S.ID_Slot
			INNER JOIN T_Location_Rows R
			ON S.ID_Row = R.ID_Row
	WHERE
			OG.ID_Order = ORDER_ID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_OrderInfo`(
	IN OrderID	INT
)
BEGIN
	SELECT	
			O.ID_Order,
            O.ID_Order_Type,
            OT.Desc_Type as Order_Type,
			CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
			CONCAT(MONTH(O.PickUp_Date), "-", DAY(O.PickUp_Date), "-", YEAR(O.PickUp_Date)) as PickUp_Date,
			CONCAT(MONTH(O.Delivery_Date), "-", DAY(O.Delivery_Date), "-", YEAR(O.Delivery_Date)) as Delivery_Date,
            CONCAT(YEAR(O.PickUp_Date), "-", MONTH(O.PickUp_Date), "-", DAY(O.PickUp_Date)) as PickUp_Date_YYYYMMDD,
			CONCAT(YEAR(O.Delivery_Date), "-", MONTH(O.Delivery_Date), "-", DAY(O.Delivery_Date)) as Delivery_Date_YYYYMMDD,
            CONCAT(U.User_FirstName, " ", U.User_LastName) as 	Client_Name,
			CONCAT("(", SUBSTR(U.User_Phone, 1, 3) , ")",SUBSTR(U.User_Phone, 4, 3),"-",SUBSTR(U.User_Phone, 7, LENGTH(U.User_Phone))) as User_Phone,
			U.User_Name as Client_Email,
            O.Receiver_Name,
			O.Street_Address,
			O.House_Address,
			O.City,
            O.State as State_Code,
			St.State_Desc as State,
			O.ZipCode,
            O.ID_Order_Status as Order_Status
	FROM 	
			T_Orders O
			INNER JOIN T_Users U
			ON O.ID_User = U.ID_User
			INNER JOIN T_Order_Status S
			ON O.ID_Order_Status = S.ID_Order_Status
			INNER JOIN T_States St
			ON O.State = St.ID_State
            INNER JOIN T_Order_Type OT
            ON O.ID_Order_Type = OT.ID_Order_Type
	WHERE	
			O.ID_Order = OrderID;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_OrderTracking`(
	IN OrderID	INT
)
BEGIN
	SELECT 	
			T.ID_Order,
			T.ID_Order_Status,
			S.Description as Desc_Status,
            CONCAT(MONTH(T.Process_Date), "-", DAY(T.Process_Date), "-", YEAR(T.Process_Date)) as Process_Date,
			T.Order_Comments
	FROM	T_Order_Tracking T
			INNER JOIN T_Order_Status S
			ON T.ID_Order_Status = S.ID_Order_Status
	WHERE 	ID_Order = OrderID
	ORDER BY T.ID_Order_Status DESC;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_WarehouseGoods_byClient`(
	IN CLIENT_ID INT
)
BEGIN
	SELECT	* 
    FROM 	v_goods_user 
    WHERE	
			ID_USER = CLIENT_ID
            AND IN_Warehouse = 1;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_WarehouseOrders_toProcess`(
	IN USER_TYPE INT
)
BEGIN

	IF USER_TYPE = 2 THEN
		SELECT	
				O.ID_Order,
				CONCAT(U.User_FirstName, " ", U.User_LastName) as 	Client_Name,
				U.User_Name as Client_Email,
				CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
				CONCAT(MONTH(O.PickUp_Date), "-", DAY(O.PickUp_Date), "-", YEAR(O.PickUp_Date)) as PickUp_Date,
				S.Description as Order_Status        
		FROM 	
				T_Orders O
				INNER JOIN T_Users U
				ON O.ID_User = U.ID_User
				INNER JOIN T_Order_Status S
				ON O.ID_Order_Status = S.ID_Order_Status
		WHERE	
				O.ID_Order_Type = 1
                AND O.Order_Active = 1
				AND (O.ID_Order_Status = 1 OR O.ID_Order_Status = 3)
		ORDER BY O.PickUp_Date;
	
    ELSEIF USER_TYPE = 3 THEN
		SELECT	
				O.ID_Order,
				CONCAT(U.User_FirstName, " ", U.User_LastName) as 	Client_Name,
				U.User_Name as Client_Email,
				CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
				CONCAT(MONTH(O.PickUp_Date), "-", DAY(O.PickUp_Date), "-", YEAR(O.PickUp_Date)) as PickUp_Date,
				S.Description as Order_Status        
		FROM 	
				T_Orders O
				INNER JOIN T_Users U
				ON O.ID_User = U.ID_User
				INNER JOIN T_Order_Status S
				ON O.ID_Order_Status = S.ID_Order_Status
		WHERE	
				O.ID_Order_Type = 1
                AND O.Order_Active = 1
				AND (O.ID_Order_Status = 2)
		ORDER BY O.PickUp_Date;
    END IF;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_WarehouseProfiles`()
BEGIN
	SELECT 	* 
    FROM 	T_Users_Profiles 
    WHERE 	Profile_ID in (1,2,3);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_WarematicCrew`()
BEGIN
	SELECT 	
		ID_User,
        User_FirstName as First_Name,
        User_LastName as Last_Name,
        User_Name,
		Concat(User_FirstName, ' ', User_LastName) as Full_Name,
        UP.Profile_ID,
        UP.Profile_Description
	FROM
		T_Users U
		INNER JOIN T_Users_Profiles UP
		ON U.Profile_ID = UP.Profile_ID
	WHERE
		(U.PROFILE_ID = 1 OR
		U.PROFILE_ID = 2 OR
		U.PROFILE_ID = 3);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_userInfo`(
	IN userId INT
)
BEGIN
	SELECT 	
		ID_User,
        User_FirstName as First_Name,
        User_LastName as Last_Name,
        User_Name,
		Concat(User_FirstName, ' ', User_LastName) as Full_Name,
        CONCAT("(", SUBSTR(User_Phone, 1, 3) , ")",SUBSTR(User_Phone, 4, 3),"-",SUBSTR(User_Phone, 7, LENGTH(User_Phone))) as User_Phone,
		Street_Address,
        House_Address,
		City,
		State,
		ZipCode
	FROM
		T_Users
	WHERE
		ID_User = userId;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_GoodsUser`(
	IN _OrderID INT,
    IN _SKU VARCHAR(8),
    IN _GoodDesc VARCHAR(60),
    IN _Unit INT,
    IN _Quantity INT,
    IN _ID_User INT
)
BEGIN

	INSERT INTO `warematic_db`.`t_goods_user`
	(
		`SKU`,
		`Good_Description`,
		`ID_Good_Unit`,
		`Available_Quantity`,
		`ID_User`
	)
	VALUES
	(
		_SKU,
		_GoodDesc,
		_Unit,
		_Quantity,
		_ID_User
	);
    
	COMMIT;

    CALL `warematic_db`.`insert_OrderGoods`(_OrderID, _SKU, _Quantity);
    

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_NewDeliveryOrder`(
	IN OrderType INT,
    IN Receiver_Name VARCHAR(60),
	IN Street VARCHAR(60),
	IN House VARCHAR(60),
	IN City VARCHAR(50),
	IN State VARCHAR(2),
	IN ZipCode VARCHAR(5),
	IN Delivery_Date DATE,
	IN IdUser INT,
	IN IdOrderStatus INT
)
BEGIN

    IF House = '' THEN
		SET House = NULL;
    END IF;

	INSERT INTO `warematic_db`.`t_orders`
	(
		`ID_Order_Type`,
        `Receiver_Name`,
		`Street_Address`,
		`House_Address`,
		`City`,
		`State`,
		`ZipCode`,
		`Delivery_Date`,
		`ID_User`,
		`ID_Order_Status`
	)
	VALUES
	(
		OrderType,
        Receiver_Name,
		Street,
		House,
		City,
		State,
		ZipCode,
		Delivery_Date,
		IdUser,
		IdOrderStatus
	);

	select @orderId := @@identity as Order_ID;
    
    CALL `warematic_db`.`insert_OrderTracking`(@orderId, IdOrderStatus, IdUser, 'New delivery order registered');
            
	COMMIT;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_NewPickUpOrder`(
	IN OrderType INT,
	IN Street VARCHAR(60),
	IN House VARCHAR(60),
	IN City VARCHAR(50),
	IN State VARCHAR(2),
	IN ZipCode VARCHAR(5),
	IN PickUp_Date DATE,
	IN IdUser INT,
	IN IdOrderStatus INT
)
BEGIN

	DECLARE _House VARCHAR(60);
    IF House = '' THEN
		SET House = NULL;
    END IF;

	INSERT INTO `warematic_db`.`t_orders`
	(
		`ID_Order_Type`,
		`Street_Address`,
		`House_Address`,
		`City`,
		`State`,
		`ZipCode`,
		`PickUp_Date`,
		`ID_User`,
		`ID_Order_Status`
	)
	VALUES
	(
		OrderType,
		Street,
		House,
		City,
		State,
		ZipCode,
		PickUp_Date,
		IdUser,
		IdOrderStatus
	);

	select @orderId := @@identity as Order_ID;
    
    CALL `warematic_db`.`insert_OrderTracking`(@orderId, IdOrderStatus, IdUser, 'New warehouse order registered');
    
	COMMIT;
     
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_OrderGoods`(
	IN OrderID INT,
    IN SKU VARCHAR(8),
    IN Quantity INT
)
BEGIN

	INSERT INTO `warematic_db`.`t_order_goods`
	(
		`ID_Order`,
		`SKU`,
		`Quantity_Order`
	)
	VALUES
	(
		OrderID,
		SKU,
		Quantity
	);
    
    COMMIT;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_OrderTracking`(
	IN OrderID INT,
    IN IdOrderStatus INT,
    IN UserID INT,
    IN Comments VARCHAR(60)
)
BEGIN
	INSERT INTO `warematic_db`.`t_order_tracking`
	(
		`ID_Order`,
		`Process_Date`,
		`ID_Order_Status`,
		`ID_User`,
		`Order_Comments`
	)
	VALUES
	(
		OrderID,
		curdate(),
		IdOrderStatus,
		UserID,
		Comments
	);
        
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_WarematicCrewUser`(
	IN FirstName	VARCHAR(50),
    IN LastName		VARCHAR(50),
    IN Email		VARCHAR(100),
    IN UserPassword	VARCHAR(100),
    IN ProfileID	INT(1)
    
)
BEGIN
	INSERT INTO T_Users(
		User_FirstName, 
        User_LastName,
		User_Name, 
        User_Password, 
		Profile_ID
	) 
	VALUES (
		FirstName, 
        LastName,
        Email,
        UserPassword,
        ProfileID
    );
    
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `placeGoods_inWarehouse`(
	IN SKU_NUM VARCHAR(8)
)
BEGIN

	SELECT 	S.ID_Slot into @Slot
	FROM	T_Location_Slots S
	WHERE 	NOT EXISTS    (
						SELECT SB.ID_Slot, COUNT(SB.ID_Bin) as Count_Bin
						FROM T_Slots_Bins SB
						WHERE S.ID_Slot = SB.ID_Slot
						GROUP BY SB.ID_Slot
						HAVING COUNT(SB.ID_Bin) = 3 )
	ORDER BY ID_Slot
	LIMIT 1;

	SELECT 	B.ID_Bin into @Bin
	FROM	T_Bins B
	WHERE	NOT EXISTS (
			SELECT * FROM T_Slots_Bins SB
			WHERE B.ID_Bin = SB.ID_Bin)
	ORDER BY B.ID_Bin
    LIMIT 1;
    
    
    UPDATE	T_Goods_User
			SET ID_Bin = @Bin,
			ID_Slot = @Slot
	WHERE	
			SKU = SKU_NUM;
    
    
    INSERT INTO `warematic_db`.`t_slots_bins`
	(
		`ID_Slot`,
		`ID_Bin`
	)
	VALUES
	(
		@Slot,
		@Bin
	);
    
    COMMIT;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_ActiveClients`()
BEGIN
	SELECT 	
		ID_User,
        User_FirstName as First_Name,
        User_LastName as Last_Name,
        User_Name,
		Concat(User_FirstName, ' ', User_LastName) as Full_Name,
        CONCAT("(", SUBSTR(User_Phone, 1, 3) , ")",SUBSTR(User_Phone, 4, 3),"-",SUBSTR(User_Phone, 7, LENGTH(User_Phone))) as User_Phone,
		Street_Address,
        House_Address,
		City,
		State,
		ZipCode
	FROM
		T_Users
	WHERE Profile_ID = 4;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_Orders_GeoDistribution`()
BEGIN
	SELECT 	City,
		COUNT(City) as Num_Orders
	FROM 
			T_Orders 
	GROUP BY City
    ORDER BY Num_Orders desc;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_WarehouseMerchandise`()
BEGIN
	SELECT	GU.* 
			, CONCAT(GU.ID_User, " - ", U.User_FirstName, " ", U.User_LastName) as User_Name
	FROM 	v_goods_user GU
			INNER JOIN T_USERS U
			ON GU.ID_User = U.ID_User
	ORDER	BY GOOD_DESC;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_numActive_Orders`()
BEGIN
	SELECT 	
			IF(ID_Order_Type = 1, "Pick Up", "Delivery") as Order_Type, 
			COUNT(ID_Order_Type) as Num_Orders 
	FROM 
			T_Orders
	WHERE 	(ID_Order_Status <> 4 AND ID_Order_Status <> 5) 
			AND Order_Active = 1 
	GROUP BY ID_Order_TYPE;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_numActive_Orders_byStatus`()
BEGIN
	SELECT 	IF(ID_Order_Type = 1, "Pick Up", "Delivery") as Order_Type, 
			CASE
				WHEN ID_Order_Status = 1 THEN "1 - In Process"
				WHEN ID_Order_Status = 2 THEN "2 - Processed"
				WHEN ID_Order_Status = 3 THEN "3 - In Transit"
			END as Status,
			ID_Order_Status,
			COUNT(ID_Order_Status) as Num_Orders
	FROM T_Orders
	WHERE 	Order_Active = 1
			AND (ID_Order_Status <> 4 AND ID_Order_Status <> 5)
	GROUP BY Order_Type, ID_Order_Status
	ORDER BY ID_Order_Status;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_GoodsUser_InWarehouse`(
	IN OrderID	INT
)
BEGIN
	UPDATE	T_Goods_User GU
		INNER JOIN T_Order_Goods OG
        ON GU.SKU = OG.SKU
	SET
		GU.IN_WAREHOUSE = 1
	WHERE
		OG.ID_Order = OrderID;
	
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_Order`(
	IN	Order_ID		INT,
    IN	ReceiverName	VARCHAR(60),
	IN	Street			VARCHAR(60),
    IN	House			VARCHAR(60),
    IN	CityAddress		VARCHAR(50),
    IN	StateAddress	VARCHAR(2),
    IN	ZipCodeAddress	VARCHAR(5),
    IN	PickUpD			DATE,
    IN	DeliveryD		DATE
)
BEGIN
	
    IF House = '' THEN
		SET House = NULL;
    END IF;
    
    IF PickUpD = '' THEN
		SET PickUpD = NULL;
    END IF;
    
    IF DeliveryD = '' THEN
		SET DeliveryD = NULL;
    END IF;

	UPDATE	T_Orders
			SET
			Receiver_Name = ReceiverName,
			Street_Address = Street,
			House_Address = House,
			City = CityAddress,
			State = StateAddress,
			ZipCode = ZipCodeAddress,
			PickUp_Date = PickUpD,
			Delivery_Date = DeliveryD
	WHERE
			ID_Order = Order_ID;
	
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_OrderStatus`(
	IN Order_ID	INT,
    IN Order_Status INT,
    IN IdUser INT,
    IN Comments VARCHAR(60)
)
BEGIN

	UPDATE 	T_Orders
			SET	ID_Order_Status = Order_Status
	WHERE	ID_Order = Order_ID;
    
    CALL `warematic_db`.`insert_OrderTracking`(Order_ID, Order_Status, IdUser, Comments);

	COMMIT;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_QuantityOfGoods`(
	IN OrderID	INT
)
BEGIN

	UPDATE	T_Goods_User GU
			INNER JOIN T_Order_Goods OG
			ON GU.SKU = OG.SKU
	SET 
			GU.Available_Quantity = GU.Available_Quantity - OG.Quantity_Order
	WHERE
		OG.ID_Order = OrderID; 

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_WarematicCrewUser`(
	IN UserID		INT,
    IN FirstName	VARCHAR(50),
    IN LastName		VARCHAR(50),
    IN Email		VARCHAR(100),
    IN ProfileID	INT(1)
)
BEGIN
	UPDATE	T_Users
	SET
			User_FirstName = FirstName,
            User_LastName = LastName,
            User_Name = Email,
            Profile_ID = ProfileID
	WHERE	ID_User = UserID;
    
    COMMIT;
		
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_WarematicGeneralUser`(
	IN UserID			INT,
    IN FirstName		VARCHAR(50),
    IN LastName			VARCHAR(50),
    IN Email			VARCHAR(100),
    IN Phone			VARCHAR(15),
    IN StreetAddress	VARCHAR(60),
	IN HouseAddress		VARCHAR(60),
    IN CityAddress		VARCHAR(50),
    IN StateAddress		VARCHAR(2),
    IN ZcAddress		VARCHAR(5)
)
BEGIN
	UPDATE	T_Users
	SET
			User_FirstName = FirstName,
            User_LastName = LastName,
            User_Name = Email,
            User_Phone = Phone,
            Street_Address = StreetAddress,
            House_Address = HouseAddress,
            City = CityAddress,
            State = StateAddress,
            ZipCode = ZcAddress
	WHERE	ID_User = UserID;
    
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualize_numOrders_by_type`()
BEGIN
	SELECT  
			IF(ID_Order_Type = 1, "Pick Up", "Delivery") as Order_Type,
			ID_Order_Status,
			COUNT(ID_Order_Status) as Num_Orders
	FROM 
			T_Orders
	WHERE 
			Order_Active = 1
	GROUP BY Order_Type, ID_Order_Status
	ORDER BY Order_Type, ID_Order_Status;
END$$
DELIMITER ;
