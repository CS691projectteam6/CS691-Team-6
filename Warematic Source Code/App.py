from flask import Flask, render_template, flash, redirect, url_for, session, request, logging
from flask_mysqldb import MySQL
from wtforms import Form, StringField, TextAreaField, PasswordField, validators
from passlib.hash import sha256_crypt
from functools import wraps
from flask_mail import Mail, Message

app = Flask(__name__)

# Config MySQL
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'warematic_db'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

# Config Flask-Mail
app.config['DEBUG'] = True
app.config['TESTING'] = False
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 465
app.config['MAIL_USE_TLS'] = False
app.config['MAIL_USE_SSL'] = True
#app.config['MAIL_DEBUG'] = True
app.config['MAIL_USERNAME'] = 'warematic.flaskapp@gmail.com'
app.config['MAIL_PASSWORD'] = 'warem@tic01'
app.config['MAIL_DEFAULT_SENDER'] = 'warematic.flaskapp@gmail.com'
app.config['MAIL_MAX_EMAILS'] = None
#app.config['MAIL_SUPPRESS_SEND'] = False
app.config['MAIL_ASCII_ATTACHMENTS'] = False

# Init MySQL
mysql = MySQL(app)

# Init Mail
mail = Mail(app)

# Index - Home
@app.route('/')
def index():
    
    if 'logged_in' in session:
        
        # Create Cursor for getting count of orders to process
        wareOrders_cursor = mysql.connection.cursor()
        
        # Getting count of warehouse orders to process
        wareOrders_cursor.execute( "call getCount_Orders_toProcess(1, %s);", str(session['user_profile']))
        count_wareOrders = wareOrders_cursor.fetchone()

        # Getting count of delivery orders to process
        wareOrders_cursor.execute( "call getCount_Orders_toProcess(2, %s);", str(session['user_profile']))
        count_deliveryOrders = wareOrders_cursor.fetchone()

        session['count_worders'] = count_wareOrders['OrdersToProcess']
        session['count_dorders'] = count_deliveryOrders['OrdersToProcess']

        wareOrders_cursor.close()

    return render_template('home.html')

# Function to Send Emails
def _sendEmail(EmailRecipient, OrderID, OrderType, OrderStatus):
    
    if (int(OrderType) == 1):
        if(int(OrderStatus) == 1):
            # Email Subject
            EmailSubject = 'A New Pick Up Order Has Been Placed'
            # Message body
            Body = 'Dear Client! You have successfully placed a new <strong>pick up</strong> order for your goodies. We will notify you '
            Body = Body + 'when it has been processed. <br /><br /> '
            Body = Body + 'All the best. '
        elif (int(OrderStatus) == 2):
            # Email Subject
            EmailSubject = 'Your Pick Up Order Has Been Processed'
            # Message body
            Body = 'Dear Client! Your pick up order has been processed. Please do not forget to have your items ready and '
            Body = Body + 'properly packaged by the pick-up-scheduled date. <br /><br /> '
            Body = Body + 'All the best. '
        elif (int(OrderStatus) == 3):
            # Email Subject
            EmailSubject = 'Your Pick Up Order Is In Transit'
            # Message body
            Body = 'Dear Client! Your pick up order is in transit to our facilities. We will notify you '
            Body = Body + 'as soon as your goodies arrive to our facilities. <br /><br /> '
            Body = Body + 'All the best. '
        else:
            # Email Subject
            EmailSubject = 'Your Pick Up Order Has Arrived To Warehouse '
            # Message body
            Body = 'Dear Client! We want to inform you that your order has been received in our facilities. Now, you can be '
            Body = Body + 'up to date about your available items in inventory and manage their storage and distribution through our system. <br /><br /> '
            Body = Body + 'Thanks for being our client. <br /><br />'
            Body = Body + 'All the best. '
    else:
        if(int(OrderStatus) == 1):
            # Email Subject
            EmailSubject = 'A New Delivery Order Has Been Placed'
            # Message body
            Body = 'Dear Client! You have successfully placed a new <strong>delivery</strong> order of your goodies. We will notify you '
            Body = Body + 'when it has been processed. <br /><br /> '
            Body = Body + 'All the best. '
        elif (int(OrderStatus) == 2):
            # Email Subject
            EmailSubject = 'Your Delivery Order Has Been Processed'
            # Message body
            Body = 'Dear Client! Your delivery order has been processed. We will notify you when your goodies '
            Body = Body + 'being in transit to their destination. <br /><br /> '
            Body = Body + 'All the best. '
        elif (int(OrderStatus) == 3):
            # Email Subject
            EmailSubject = 'Your Delivery Order Is In Transit'
            # Message body
            Body = 'Dear Client! Your delivery order is in transit. We will notify you '
            Body = Body + 'as soon as your goodies arrive to their destination. <br /><br /> '
            Body = Body + 'All the best. '
        else:
            # Email Subject
            EmailSubject = 'Your Order Has Been Arrived at Destination '
            # Message body
            Body = 'Dear Client! We want to inform you that your goodies has arrived at their destination. Please, check '
            Body = Body + 'your available goodies in inventory through our system and request a new pick up if you need to. <br /><br /> '
            Body = Body + 'Thanks for being our client. <br /><br />'
            Body = Body + 'All the best. '
        
    htmlBody = '<!DOCTYPE html>'
    htmlBody = htmlBody + '<html> '
    htmlBody = htmlBody + '<head> '
    htmlBody = htmlBody + '<meta name="viewport" content="width=device-width, initial-scale=1.0" /> '
    htmlBody = htmlBody + '</head> '
    htmlBody = htmlBody + '<body style="background: #f7f7f7;"> '
    htmlBody = htmlBody + '<div style="width:70%; margin-left:auto; margin-right: auto; padding: 10px; margin-top:10px; background: white;"> '
    htmlBody = htmlBody + '<p style="text-align: center; font-family: Verdana, Geneva, Tahoma, sans-serif; font-size: 40px;"> '
    htmlBody = htmlBody + '<span style="color: #f03a02;">W</span>AREMATIC <br /> '
    htmlBody = htmlBody + '<span style="text-align: center; color: #2e2e2e; font-family: Segoe UI, Tahoma, Geneva, Verdana, sans-serif; font-size: 14px;"> '
    htmlBody = htmlBody + 'Automated Warehouse Logistic '
    htmlBody = htmlBody + '</span> '
    htmlBody = htmlBody + '</p> '
    htmlBody = htmlBody + '<p style="text-align: center; font-weight: bold; color: #333333; font-family: Arial, Helvetica, sans-serif; font-size: 24px;"> '
    htmlBody = htmlBody + EmailSubject # Type of Order Titl
    htmlBody = htmlBody + '</p> '   
    htmlBody = htmlBody + '<div style="width: 70%; margin-left: auto; margin-right: auto;"> '
    htmlBody = htmlBody + '<p style="text-align: right; color: #757571; font-family: Segoe UI, Tahoma, Geneva, Verdana, sans-serif; font-size: 17px;"> '
    htmlBody = htmlBody + '<span >ORDER: ' + str(OrderID) + '</span> ' # Order ID
    htmlBody = htmlBody + '</p> '
    htmlBody = htmlBody + '<p style="text-align: justify; color: #757571; font-family: Segoe UI, Tahoma, Geneva, Verdana, sans-serif; font-size: 16px;"> '
    htmlBody = htmlBody +  Body
    htmlBody = htmlBody + '</p><p>&nbsp;</p>'
    htmlBody = htmlBody + '</div> '
    htmlBody = htmlBody + '</div> '
    htmlBody = htmlBody + '</body> '
    htmlBody = htmlBody + '</html>'

    msg = Message(EmailSubject, recipients=[EmailRecipient])
    msg.html = htmlBody
    mail.send(msg)

class RegisterForm(Form):
    username = StringField('Username', [
        validators.DataRequired(),
        validators.Length(min=1, max=50)
    ])
    password = PasswordField('Password', [
        validators.DataRequired(),
        validators.EqualTo('confirm', message='Passwords do not match')
    ])
    confirm = PasswordField('Confirm Password')
    fname = StringField('First Name', [
        validators.DataRequired(),
        validators.Length(min=1, max=50)
    ])
    lname = StringField('Last Name', [
        validators.DataRequired(),
        validators.Length(min=1, max=50)
    ])
    phone = StringField('Phone', [validators.Length(min=1, max=15)])
    street = StringField('Street', [validators.Length(min=0, max=60)])
    house = StringField('House', [validators.Length(min=0, max=60)])
    city = StringField('City', [validators.Length(min=0, max=50)])
    state = StringField('State', [validators.Length(min=0, max=2)])
    zipcode = StringField('ZipCode', [validators.Length(min=0, max=5)])

# User Register
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegisterForm(request.form)
    if request.method == 'POST' and form.validate():
        username = form.username.data
        password = sha256_crypt.encrypt(str(form.password.data))
        fname = form.fname.data
        lname = form.lname.data
        phone = form.phone.data
        street = form.street.data
        house = form.house.data
        city = form.city.data
        state = form.state.data
        zipcode = form.zipcode.data
        profileId = 4

        # Create Cursor
        cur = mysql.connection.cursor()

        # Execute query
        cur.execute("INSERT INTO T_Users(User_Name, User_Password, User_FirstName, User_LastName, User_Phone, Street_Address, House_Address, City, State, ZipCode, Profile_ID) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (username, password, fname, lname, phone, street, house, city, state, zipcode, profileId))

        # Commit to DB
        mysql.connection.commit()

        # Close Connection
        cur.close()

        flash('You are now registered and can log in', 'success')

        redirect(url_for('index'))
    
    return render_template('register.html', form=form)
    
# User Login
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # Get form fields
        username = request.form['username']
        password_candidate = request.form['password']

        # Create Cursor
        cur = mysql.connection.cursor()

        # Get user by username
        result = cur.execute("SELECT * FROM T_Users WHERE User_Name = %s", [username])

        if result > 0:
            # Get stored hash
            data = cur.fetchone()
            password = data['User_Password']
        
            # Compare Passwords
            if sha256_crypt.verify(password_candidate, password):
                print("PASSWORD MATCHED")
                # Passed
                session['logged_in'] = True
                session['username'] = username
                session['firstname'] = data['User_FirstName']
                session['user_id'] = data['ID_User']
                session['user_profile'] = data['Profile_ID']

                #flash('You are now logged in', 'success')
                return redirect(url_for('index'))
            else:
                error = "Invalid login"
                return render_template('login.html', error=error)
        else:
            error = "Username nor found"
            return render_template('login.html', error=error)
        
        # Close connection
        cur.close()
    
    return render_template('login.html')

# Check if user logged in
def is_logged_in(f):
    @wraps(f)
    def wrap(*args, **kwargs):
        if 'logged_in' in session:
            return f(*args, **kwargs)
        else:
            flash('Unauthorized, Please login', 'danger')
            return redirect(url_for('login')) 
    return wrap

# Check if user logged in
def is_warehouseClerk(f):
    @wraps(f)
    def wrap(*args, **kwargs):
        if 'logged_in' in session:
            if session['user_profile'] == 2 or session['user_profile'] == 3:
                return f(*args, **kwargs)
            else:
                flash('Unauthorized user', 'danger')
                return redirect(url_for('login'))
        else:
            flash('Unauthorized, Please login', 'danger')
            return redirect(url_for('login'))
    return wrap

# Logout
@app.route('/logout')
def logout():
    session.clear()
    #flash('You are now logged out', 'success')
    return redirect(url_for('index'))

# Dashboard
@app.route('/dashboard')
@is_logged_in
def dashboard():
    return render_template('dashboard.html')

# New Pick Up Order
@app.route('/NewPickUpOrder', methods=['GET', 'POST'])
@is_logged_in
def NewPickUpOrder():
    # Get User ID
    user_id = session['user_id']

    # Create Cursor for getting user information.
    cur = mysql.connection.cursor()
    # Create Cursor for getting states info.
    curStates = mysql.connection.cursor()

    # Get user information
    result = cur.execute( "call get_userInfo(%s);", [user_id] )
    userInfo = cur.fetchone()

    # Get States information
    curStates.execute("SELECT * FROM T_States")
    states = curStates.fetchall()
    
    if request.method == 'POST':
        orderType = 1
        orderStatus = 1
        clientEmail = request.form['email']
        street = request.form['street']
        house = request.form['house']
        city = request.form['city']
        state = request.form['state']
        zipCode = request.form['zipCode']
        pickupdate = request.form['pickupdate']

        numItem = request.form['numOfItems']
        int_numItem = int(numItem) + 1

        # New Order Cursor
        order_cur = mysql.connection.cursor()

        # Insert Order into T_Orders
        args = (orderType, street, house, city, state, zipCode, pickupdate, user_id, orderStatus)
        order_cur.callproc("insert_NewPickUpOrder", args)
        recordsInserted = order_cur.fetchone()

        # Validate if order was inserted
        if len(recordsInserted) > 0:
            
            # Capture the ID of the last order inserted
            order_id = recordsInserted['Order_ID']

            # Close Connection
            order_cur.close()

             # New Order Goods Cursor
            orderGoods_cur = mysql.connection.cursor()

            for x in range(1, int_numItem):
                # Capture the Goodies from the form
                sku = request.form['sku' + str(x)]
                itemDesc = request.form['itemdesc' + str(x)]
                itemUnit = request.form['unit' + str(x)]
                quantity = request.form['qty' + str(x)]
                _args = (order_id, sku, itemDesc, itemUnit, quantity, user_id)
                # Insert User Goodies and Goodies of the order in DB
                orderGoods_cur.callproc("insert_GoodsUser", _args)
            
            _sendEmail(clientEmail, order_id, orderType, orderStatus)
            
            msg = 'The pick up order has been placed successfully'
            return render_template('NewPickUpOrder.html', userInfo=userInfo, states=states, msg=msg)
        
        # Close Connection
        orderGoods_cur.close()

    else:
        
        if result > 0:
            return render_template('NewPickUpOrder.html', userInfo=userInfo, states=states)
        else:
            msg = 'No user information found'
            return render_template('NewPickUpOrder.html', msg=msg)
        
    # Close connection
    cur.close()
    curStates.close()


# New Delivery Order
@app.route('/NewDeliveryOrder', methods=['GET', 'POST'])
@is_logged_in
def NewDeliveryOrder():
    # Get User ID
    user_id = session['user_id']
    
    # Create Cursor for getting user information.
    cur = mysql.connection.cursor()
    # Create Cursor for getting states info.
    curStates = mysql.connection.cursor()
    # Create Cursor for getting products available in warehouse.
    goods_cursor = mysql.connection.cursor()

    # Get user information
    result = cur.execute( "call get_userInfo(%s);", [user_id] )
    userInfo = cur.fetchone()

    # Get States information
    curStates.execute("SELECT * FROM T_States")
    states = curStates.fetchall()
    curStates.close()

    # Get user products available in warehouse.
    result = goods_cursor.execute( "call get_WarehouseGoods_byClient(%s);", str(user_id))
    goods = goods_cursor.fetchall()
    goods_cursor.close()
    
    if request.method == 'POST':
        orderType = 2
        orderStatus = 1
        receiver = request.form['receiver_name']
        clientEmail = request.form['email']
        street = request.form['street']
        house = request.form['house']
        city = request.form['city']
        state = request.form['state']
        zipCode = request.form['zipCode']
        deliverydate = request.form['deliverydate']

        numItem = request.form['totalItems']
        int_numItems = int(numItem)

        # New Order Cursor
        order_cur = mysql.connection.cursor()

        # Insert Order into T_Orders
        args = (orderType, receiver, street, house, city, state, zipCode, deliverydate, user_id, orderStatus)
        order_cur.callproc("insert_NewDeliveryOrder", args)
        recordsInserted = order_cur.fetchone()

        # Validate if order was inserted
        if len(recordsInserted) > 0:
            
            # Capture the ID of the last order inserted
            order_id = recordsInserted['Order_ID']

            # Close Connection
            order_cur.close()

            # New Order Goods Cursor
            orderGoods_cur = mysql.connection.cursor()
        
            for x in range(1, int_numItems):
                # Validate Products Selected to deliver
                if ( request.form.get('Item_'+ str(x)) ):
                    # Capture the Goodies from the form
                    sku = request.form.get('Item_'+ str(x))
                    quantity = request.form['quantity_' + str(x)]
                    _args = (order_id, sku, quantity)
                    # Insert Goodies of the order in DB
                    orderGoods_cur.callproc("insert_OrderGoods", _args)
            
            _sendEmail(clientEmail, order_id, orderType, orderStatus)

            # Close connection
            orderGoods_cur.close()

            msg = 'The Delivery order has been placed successfully'
            return render_template('NewDeliveryOrder.html', userInfo=userInfo, states=states, goods=goods, msg=msg)      
    
    else:

        if result > 0:
            return render_template('NewDeliveryOrder.html', userInfo=userInfo, states=states, goods=goods)
        else:
            error = 'There is no available products in your warehouse'
            return render_template('NewDeliveryOrder.html', userInfo=userInfo, states=states, goods=goods, error=error)
        
        
    # Close connection
    cur.close()
    
# My Warehouse
@app.route('/MyWarehouse', methods=['GET', 'POST'])
@is_logged_in
def MyWarehouse():
    # Create Cursor for getting warehouse orders to process.
    goods_cursor = mysql.connection.cursor()

    # Get users orders information
    result = goods_cursor.execute( "call get_WarehouseGoods_byClient(%s);", str(session['user_id']))
    warehouseGoods = goods_cursor.fetchall()

    if result > 0:
        return render_template('MyWarehouse.html', warehouseGoods=warehouseGoods)
    else:
        warning = 'There is no available goods in inventory'
        return render_template('MyWarehouse.html', warning=warning)
        
    goods_cursor.close()

# View Warehouse Orders
@app.route('/ViewWarehouseOrders', methods=['GET', 'POST'])
@is_warehouseClerk
def ViewWarehouseOrders():
    if request.method == 'POST':
        order_id = request.form['order_id']
    else:
        # Create Cursor for getting warehouse orders to process.
        orders_cursor = mysql.connection.cursor()

        # Get users orders information
        result = orders_cursor.execute( "call get_WarehouseOrders_toProcess(%s);", str(session['user_profile']))
        warehouseOrders = orders_cursor.fetchall()

        if result > 0:
            return render_template('ViewWarehouseOrders.html', warehouseOrders=warehouseOrders)
        else:
            warning = ' There is no warehouse orders to process'
            return render_template('ViewWarehouseOrders.html', warning=warning)
        
        orders_cursor.close()

# Detail Warehouse Order and Orders Processing
@app.route('/Detail_WOrder/<string:id>', methods=['GET', 'POST'])
@is_warehouseClerk
def DetailWarehouseOrder(id):

    if request.method == 'POST':

        # Get User ID
        user_id = session['user_id']

        # Get User Profile
        user_profile = session['user_profile']
        
        # Requesting Order Data for updating status
        orderID = request.form['orderId']
        orderStatus = request.form['orderStatus']
        clientEmail = request.form['clientEmail']

        # Update Order Cursor
        order_cur = mysql.connection.cursor()
        
        if int(user_profile) == 2:
            # Check if the order is In Process
            if int(orderStatus) == 1:
                orderStatus = 2
                comments = "Order processed in system"
                # Update Order Status in T_Orders
                args = (orderID, orderStatus, user_id, comments)
                order_cur.callproc("update_OrderStatus", args)

                # Close Connection
                order_cur.close()

                totalItems = int(request.form['totalItems'])

                # Goods Cursor
                goods_cursor = mysql.connection.cursor()

                for x in range(1, totalItems):
                    sku = request.form['Item_' + str(x)]
                    # Place goodies in Warehouse
                    goods_cursor.callproc("placeGoods_inWarehouse", [sku])

                # Close Connection
                goods_cursor.close()

                _sendEmail(clientEmail, orderID, 1, orderStatus)

            # Check if the order is In Transit
            elif int(orderStatus) == 3:
                orderStatus = 4
                comments = "Order received at warehouse"
                # Update Order Status in T_Orders
                args = (orderID, orderStatus, user_id, comments)
                order_cur.callproc("update_OrderStatus", args)

                # Marking Goods as RECEIVED IN WAREHOUSE
                order_cur.callproc("update_GoodsUser_InWarehouse", [orderID])

                # Close Connection
                order_cur.close()

                _sendEmail(clientEmail, orderID, 1, orderStatus)
        elif int(user_profile) == 3:
            # Check if the order is Processed
            if int(orderStatus) == 2:
                orderStatus = 3
                comments = "Order is in transit to warehouse"
                # Update Order Status in T_Orders
                args = (orderID, orderStatus, user_id, comments)
                order_cur.callproc("update_OrderStatus", args)

                # Close Connection
                order_cur.close()

                _sendEmail(clientEmail, orderID, 1, orderStatus)                

        flash('The order has been processed successfully', 'success')
        return redirect(url_for('ViewWarehouseOrders'))
    else:
        # Create Cursor for getting order information by id.
        order_cursor = mysql.connection.cursor()

        # Create Cursor for getting order goods.
        goods_cursor = mysql.connection.cursor()

        # Get order information by id.
        result = order_cursor.execute( "call get_OrderInfo(%s);", [id])
        order = order_cursor.fetchone()

        # Get order goods by id.
        goods_cursor.execute( "call get_OrderGoods_toPickUP(%s);", [id])
        goods = goods_cursor.fetchall()

        if result > 0:
            return render_template('DetailWarehouseOrder.html', order=order, goods=goods)
        else:
            error = 'Order ID was not found'
            return render_template('DetailWarehouseOrder.html', error=error, order=order)
        
        order_cursor.close()
        goods_cursor.close()

# View Delivery Orders
@app.route('/ViewDeliveryOrders', methods=['GET', 'POST'])
@is_warehouseClerk
def ViewDeliveryOrders():
    if request.method == 'POST':
        order_id = request.form['order_id']
    else:
        # Create Cursor for getting warehouse orders to process.
        orders_cursor = mysql.connection.cursor()

        # Get users orders information
        result = orders_cursor.execute("call get_DeliveryOrders_toProcess(%s);", str(session['user_profile']))
        deliveryOrders = orders_cursor.fetchall()

        if result > 0:
            return render_template('ViewDeliveryOrders.html', deliveryOrders=deliveryOrders)
        else:
            warning = ' There is no delivery orders to process'
            return render_template('ViewDeliveryOrders.html', warning=warning)
        
        orders_cursor.close()

# Detail Delivery Order and Orders Processing
@app.route('/Detail_DOrder/<string:id>', methods=['GET', 'POST'])
@is_warehouseClerk
def Detail_DOrder(id):
    if request.method == 'POST':
        # Get User ID
        user_id = session['user_id']

        # Get User Profile
        user_profile = session['user_profile']
        
        # Requesting Order Data for updating status
        orderID = request.form['orderId']
        orderStatus = request.form['orderStatus']
        clientEmail = request.form['ClientEmail']

        # Update Order Cursor
        order_cur = mysql.connection.cursor()
        
        if int(user_profile) == 2:
            # Check if the order is In Process
            if int(orderStatus) == 1:
                orderStatus = 2
                comments = "Order has been processed in the system"
                # Update Order Status in T_Orders
                args = (orderID, orderStatus, user_id, comments)
                order_cur.callproc("update_OrderStatus", args)

                # Close Connection
                order_cur.close()

                _sendEmail(clientEmail, orderID, 2, orderStatus)

        elif int(user_profile) == 3:
            # Check if the order is Processed
            if int(orderStatus) == 2:
                orderStatus = 3
                comments = "Order is in transit to its destination"
                # Update Order Status in T_Orders
                args = (orderID, orderStatus, user_id, comments)
                order_cur.callproc("update_OrderStatus", args)

                # Close Connection
                order_cur.close()

                _sendEmail(clientEmail, orderID, 2, orderStatus)
            
            # Check if the order is In Transit
            elif int(orderStatus) == 3:
                orderStatus = 5
                comments = "Order received at its destination"
                # Update Order Status in T_Orders
                args = (orderID, orderStatus, user_id, comments)
                order_cur.callproc("update_OrderStatus", args)

                # Marking Goods as RECEIVED IN WAREHOUSE
                order_cur.callproc("update_QuantityOfGoods", [orderID])

                # Close Connection
                order_cur.close()

                _sendEmail(clientEmail, orderID, 2, orderStatus)           

        flash('The order has been processed successfully', 'success')
        return redirect(url_for('ViewDeliveryOrders'))
    else:
        # Create Cursor for getting order information by id.
        order_cursor = mysql.connection.cursor()

        # Create Cursor for getting order goods.
        goods_cursor = mysql.connection.cursor()

        # Get order information by id.
        result = order_cursor.execute( "call get_OrderInfo(%s);", [id])
        order = order_cursor.fetchone()

        # Get order goods for delivery  by id.
        goods_cursor.execute( "call get_OrderGoods_to_Delivery(%s);", [id])
        goods = goods_cursor.fetchall()

        if result > 0:
            return render_template('DetailDeliveryOrder.html', order=order, goods=goods)
        else:
            error = 'Order ID was not found'
            return render_template('DetailDeliveryOrder.html', error=error, order=order)

        order_cursor.close()
        goods_cursor.close()

    return render_template('DetailDeliveryOrder.html')

# View My Orders
@app.route('/ViewMyOrders', methods=['GET', 'POST'])
@is_logged_in
def ViewMyOrders():
    if request.method == 'POST':
        order_id = request.form['order_id']
    else:
        # Create Cursor for getting my orders.
        orders_cursor = mysql.connection.cursor()

        # Get users orders information
        result = orders_cursor.execute("call get_Client_Orders(%s);", str(session['user_id']))
        ClientOrders = orders_cursor.fetchall()

        if result > 0:
            return render_template('ViewMyOrders.html', ClientOrders=ClientOrders)
        else:
            warning = ' There is no orders to display'
            return render_template('ViewMyOrders.html', warning=warning)
        
        orders_cursor.close()

# View Tracking Order
@app.route('/ViewMyOrderTracking/<string:id>', methods=['GET', 'POST'])
def ViewMyOrderTracking(id):
    
    if request.method == 'POST':
        # Get User ID
        user_id = session['user_id']
    else:
        # Create Cursor for getting order information by id.
        order_cursor = mysql.connection.cursor()

        # Create Cursor for getting order goods.
        goods_cursor = mysql.connection.cursor()

        # Create Cursor for getting order tracking.
        tracking_cursor = mysql.connection.cursor()

        # Get order information by order id.
        result = order_cursor.execute( "call get_OrderInfo(%s);", [id])
        order = order_cursor.fetchone()

        # Get order goods by order id.
        goods_cursor.execute("call get_OrderGoods(%s);", [id])
        goods = goods_cursor.fetchall()

        # Get order tracking information by order id.
        tracking_cursor.execute( "call get_OrderTracking(%s);", [id])
        tracks = tracking_cursor.fetchall()

        if result > 0:
            return render_template('ViewMyOrderTracking.html', order=order, tracks=tracks, goods=goods)
        else:
            error = 'Order ID was not found'
            return render_template('ViewMyOrderTracking.html', error=error, order=order)

        order_cursor.close()
        goods_cursor.close()
        tracking_cursor.close()
    
    return render_template('ViewMyOrderTracking.html')


if __name__ == '__main__':
    app.secret_key='secret1234'
    app.run(port = 3000, debug = True)