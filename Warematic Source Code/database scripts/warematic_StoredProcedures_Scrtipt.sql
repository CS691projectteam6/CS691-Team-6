USE warematic_db;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_Client_Orders`(
	IN ORDER_ID	 INT
)
BEGIN
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
			ID_User = ORDER_ID;
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_OrderInfo`(
	IN OrderID	INT
)
BEGIN
	SELECT	
			O.ID_Order,
            OT.Desc_Type as Order_Type,
			CONCAT(MONTH(O.Order_Date), "-", DAY(O.Order_Date), "-", YEAR(O.Order_Date)) as Order_Date,
			CONCAT(MONTH(O.PickUp_Date), "-", DAY(O.PickUp_Date), "-", YEAR(O.PickUp_Date)) as PickUp_Date,
			CONCAT(MONTH(O.Delivery_Date), "-", DAY(O.Delivery_Date), "-", YEAR(O.Delivery_Date)) as Delivery_Date,
            CONCAT(U.User_FirstName, " ", U.User_LastName) as 	Client_Name,
			CONCAT("(", SUBSTR(U.User_Phone, 1, 3) , ")",SUBSTR(U.User_Phone, 4, 3),"-",SUBSTR(U.User_Phone, 7, LENGTH(U.User_Phone))) as User_Phone,
			U.User_Name as Client_Email,
            O.Receiver_Name,
			O.Street_Address,
			O.House_Address,
			O.City,
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_userInfo`(
	IN userId INT
)
BEGIN
	SELECT 	
		ID_User,
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
				AND (O.ID_Order_Status = 2)
		ORDER BY O.PickUp_Date;
    END IF;

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
				AND (ID_Order_Status = 1 OR ID_Order_Status = 3);
                
	ELSEIF USER_TYPE = 3 THEN
		
        IF ORDER_TYPE = 1 THEN
			SELECT	COUNT(*) as OrdersToProcess 
			FROM 	T_Orders 
			WHERE	
					ID_Order_Type = ORDER_TYPE
					AND (ID_Order_Status = 2);
        ELSE
			SELECT	COUNT(*) as OrdersToProcess 
			FROM 	T_Orders 
			WHERE	
					ID_Order_Type = ORDER_TYPE
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













