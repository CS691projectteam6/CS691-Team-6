from flask import Flask, send_file, render_template, flash, redirect, url_for, session, request, logging
from flask_mysqldb import MySQL
from wtforms import Form, StringField, TextAreaField, PasswordField, validators
from wtforms.validators import DataRequired, Email
from passlib.hash import sha256_crypt
from functools import wraps
from flask_mail import Mail, Message
import uuid
from itsdangerous import URLSafeSerializer, SignatureExpired

import MySQLdb
import pandas as pd
import numpy as np
import io
import base64
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
import matplotlib.pyplot as plt
import seaborn as sns

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

class ResetForm(Form):
    email = StringField('Email', validators=[DataRequired(), Email(message="Invalid Email")])

class ChangePasswordForm(Form):
    password = PasswordField('Password', [
        validators.DataRequired(),
        validators.EqualTo('confirm', message='Passwords do not match')
    ])
    confirm = PasswordField('Confirm Password')

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
                #print("PASSWORD MATCHED")
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

@app.route('/reset_password', methods=['POST', 'GET'])
def reset_password():
    form = ResetForm(request.form)
    if request.method == 'POST' and form.validate():
        email = request.form["email"]
    return render_template('ResetPassword.html', form=form)

@app.route('/tokenSubmit', methods=['POST', 'GET'])
def tokenSubmit():
    form = ResetForm(request.form)
    if request.method == 'POST' and form.validate():
        email = request.form['email']
        
        # Create Cursor
        cur = mysql.connection.cursor()

        # Validate Email Exists
        result = cur.execute("SELECT * FROM T_Users WHERE User_Name = %s", [email])

        if result > 0:
            # Get stored hash
            data = cur.fetchone()
            session['email'] = data["User_Name"]
            print(uuid.uuid4().hex.upper())
            token = uuid.uuid4().hex.upper()

            # Execute query
            cur.execute("INSERT INTO T_Token_Email(Token, User_Email) VALUES (%s,%s)", (token, email))

            # Commit to DB
            mysql.connection.commit()

            # Close Connection
            cur.close()

            msg = Message(subject='Password Reset', sender='warematic.flaskapp@gmail.com',
                          recipients=[request.form['email']])
            link = url_for('conf_email', token=token, _external=True)
            msg.body = render_template('sentmail_token.html', token=token, link=link)
            mail.send(msg)

            flash('Reset Link has been sent to your Email', 'success')
            # print("checking for real")
            return redirect(url_for('reset_password'))
        else:

            msg = Message(subject='Password Reset', sender='warematic.flaskapp@gmail.com',
                          recipients=[request.form['email']])
            msg.body = "This email does not exist in our system, " \
                       "if you not the one who entered this mail ignore this message"
            mail.send(msg)
            flash('Email does not exist or wrong username or password!', 'danger')
            return redirect(url_for('reset_password'))

    return render_template('home.html', form=form)

@app.route('/conf_email/<token>')
def conf_email(token):
    try:
        email = token
    except SignatureExpired:
        return '<h1>The token is expired!</h1>'
    return redirect(url_for('set_newPassword', email=email))

@app.route('/set_newPassword/<email>')
def set_newPassword(email):
    return redirect(url_for('password_confirm', email=email))

@app.route('/password_confirm/<email>', methods=['GET', 'POST'])
def password_confirm(email):
    form = ChangePasswordForm(request.form)
    if request.method == 'POST' and form.validate():
        #password = request.form['password']
        password = sha256_crypt.encrypt(str(form.password.data))
        _token = email
        print("Update Password...")
        
        # Create Cursor
        cur = mysql.connection.cursor()

        # Validate Email Exists
        result = cur.execute("SELECT * FROM T_Token_Email WHERE Token = %s", [_token])

        if result > 0:

            data = cur.fetchone()
            userEmail = data["User_Email"]
            print(password)
            print(userEmail)
        
            # Execute query
            cur.execute("UPDATE T_Users SET User_Password =%s WHERE User_Name = %s", (password, userEmail))

            # Commit to DB
            mysql.connection.commit()

            # Close Connection
            cur.close()
            flash('Password Updated Succesfully', 'success')
            return redirect(url_for('login'))

    return render_template('change_password.html', form=form, email=email)

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
def is_admin(f):
    @wraps(f)
    def wrap(*args, **kwargs):
        if 'logged_in' in session:
            if session['user_profile'] == 1:
                return f(*args, **kwargs)
            else:
                flash('Unauthorized user', 'danger')
                return redirect(url_for('login'))
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

    user_id = session['user_id']

    # Create Cursor for getting order types info.
    curOrderType = mysql.connection.cursor()

    # Get Order Types information
    curOrderType.execute("SELECT * FROM T_Order_Type")
    oTypes = curOrderType.fetchall()

    # Create Cursor for getting order status info.
    curOrderStatus = mysql.connection.cursor()

    # Get Order Status information
    curOrderStatus.execute("SELECT * FROM T_Order_Status WHERE ID_Order_Status <> 4 AND ID_Order_Status <> 5")
    oStatus = curOrderStatus.fetchall()

    if request.method == 'POST':
        order_id = request.form['orderId']
        order_type = request.form['orderType']
        order_status = request.form['orderStatus']
        ini_date = request.form['iniDate']
        end_date = request.form['endDate']

        # Create Cursor for getting my FILTERED orders 
        ordersF_cur = mysql.connection.cursor()
        
        #Execute Procedure to Delete an Order
        args = (user_id, order_id, order_type, order_status, ini_date, end_date)
        result = ordersF_cur.execute("call get_Client_Orders(%s,%s,%s,%s,%s,%s);", args)
        ClientOrders = ordersF_cur.fetchall()

        if result > 0:
            return render_template('ViewMyOrders.html', ClientOrders=ClientOrders, oTypes=oTypes, oStatus=oStatus)
        else:
            warning = ' There is no orders to display'
            return render_template('ViewMyOrders.html', warning=warning, oTypes=oTypes, oStatus=oStatus)
        
        # Close Connection
        ordersF_cur.close()

    else:

        order_id = ''
        order_type = ''
        order_status = ''
        ini_date = ''
        end_date = ''

        # Create Cursor for getting my orders.
        orders_cursor = mysql.connection.cursor()

        # Get users orders information
        args = (user_id, order_id, order_type, order_status, ini_date, end_date)
        result = orders_cursor.execute("call get_Client_Orders(%s,%s,%s,%s,%s,%s);", args)
        ClientOrders = orders_cursor.fetchall()

        print("My Orders Result = ", result)

        if result > 0:
            return render_template('ViewMyOrders.html', ClientOrders=ClientOrders, oTypes=oTypes, oStatus=oStatus)
        else:
            warning = ' There is no orders to display'
            return render_template('ViewMyOrders.html', warning=warning, oTypes=oTypes, oStatus=oStatus)
        
        orders_cursor.close()
    
    curOrderType.close()
    curOrderStatus.close()

# View Orders History
@app.route('/ViewOrdersHistory', methods=['GET', 'POST'])
@is_logged_in
def ViewOrdersHistory():

    user_id = session['user_id']

    # Create Cursor for getting order types info.
    curOrderType = mysql.connection.cursor()

    # Get Order Types information
    curOrderType.execute("SELECT * FROM T_Order_Type")
    oTypes = curOrderType.fetchall()

    # Create Cursor for getting order status info.
    curOrderStatus = mysql.connection.cursor()

    # Get Order Status information
    curOrderStatus.execute("SELECT * FROM T_Order_Status WHERE ID_Order_Status = 4 OR ID_Order_Status = 5 OR ID_Order_Status = 6")
    oStatus = curOrderStatus.fetchall()

    if request.method == 'POST':
        order_id = request.form['orderId']
        order_type = request.form['orderType']
        order_status = request.form['orderStatus']
        ini_date = request.form['iniDate']
        end_date = request.form['endDate']

        # Create Cursor for getting my FILTERED orders 
        ordersF_cur = mysql.connection.cursor()
        
        #Execute Procedure to Delete an Order
        args = (user_id, order_id, order_type, order_status, ini_date, end_date)
        result = ordersF_cur.execute("call get_Client_HistoryOrders(%s,%s,%s,%s,%s,%s);", args)
        ClientOrdersHist = ordersF_cur.fetchall()

        if result > 0:
            return render_template('ViewOrdersHistory.html', ClientOrdersHist=ClientOrdersHist, oTypes=oTypes, oStatus=oStatus)
        else:
            warning = ' There is no orders to display'
            return render_template('ViewOrdersHistory.html', warning=warning, oTypes=oTypes, oStatus=oStatus)
        
        # Close Connection
        ordersF_cur.close()
    
    else:

        order_id = ''
        order_type = ''
        order_status = ''
        ini_date = ''
        end_date = ''

        # Create Cursor for getting my orders.
        orders_cursor = mysql.connection.cursor()

        # Get users orders history information
        args = (user_id, order_id, order_type, order_status, ini_date, end_date)
        result = orders_cursor.execute("call get_Client_HistoryOrders(%s,%s,%s,%s,%s,%s);", args)
        ClientOrdersHist = orders_cursor.fetchall()

        if result > 0:
            return render_template('ViewOrdersHistory.html', ClientOrdersHist=ClientOrdersHist, oTypes=oTypes, oStatus=oStatus)
        else:
            warning = 'There is no orders to display'
            return render_template('ViewOrdersHistory.html', warning=warning, oTypes=oTypes, oStatus=oStatus)
        
        orders_cursor.close()
    
    curOrderType.close()
    curOrderStatus.close()

# View Order Detail
@app.route('/OrderDetail/<string:id>', methods=['GET', 'POST'])
@is_logged_in
def OrderDetail(id):
    
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
            return render_template('OrderDetail.html', order=order, tracks=tracks, goods=goods)
        else:
            error = 'Order ID was not found'
            return render_template('OrderDetail.html', error=error, order=order)

        order_cursor.close()
        goods_cursor.close()
        tracking_cursor.close()
    
    return render_template('ViewMyOrderTracking.html')

# View Tracking Order
@app.route('/ViewMyOrderTracking/<string:id>', methods=['GET', 'POST'])
@is_logged_in
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

# Delete Orders by Order ID
@app.route('/DeleteOrder/<string:order_id>', methods=['POST'])
@is_logged_in
def DeleteOrder(order_id):
    if request.method == 'POST':
        try:

            order_type = ''
            order_status = ''
            ini_date = ''
            end_date = ''
            

            args2 = (str(session['user_id']), '', order_type, order_status, ini_date, end_date)

            # Update Order Cursor
            delete_cur = mysql.connection.cursor()
        
            #Execute Procedure to Delete an Order
            args = (order_id,)
            delete_cur.callproc("delete_OrderByUser", args)
        
            # Close Connection
            delete_cur.close()

            msg = 'The order has been deleted successfully'

            # Create Cursor for getting user orders.
            orders_cursor = mysql.connection.cursor()

            # Get user orders 
            result = orders_cursor.execute("call get_Client_Orders(%s,%s,%s,%s,%s,%s);", args2)
            ClientOrders = orders_cursor.fetchall()

            if result > 0:
                return render_template('ViewMyOrders.html', ClientOrders=ClientOrders, msg=msg)
            
            orders_cursor.close()

        except ValueError:
            print("System Error. MySql execution bug: delete_OrderByUser")

# Update Orders by Order ID
@app.route('/UpdateOrderDetail/<string:id>', methods=['GET', 'POST'])
@is_logged_in
def UpdateOrderDetail(id):
    
    # Create Cursor for getting order information by id.
    order_cursor = mysql.connection.cursor()

    # Create Cursor for getting order goods.
    goods_cursor = mysql.connection.cursor()

    # Create Cursor for getting states info.
    curStates = mysql.connection.cursor()

    # Create Cursor for getting units.
    curUnits = mysql.connection.cursor()

    # Get order information by order id.
    result = order_cursor.execute( "call get_OrderInfo(%s);", [id])
    order = order_cursor.fetchone()

    # Get order goods by order id.
    goods_cursor.execute("call get_OrderGoods(%s);", [id])
    goods = goods_cursor.fetchall()

    # Get States information
    curStates.execute("SELECT * FROM T_States")
    states = curStates.fetchall()

    # Get Units information
    curUnits.execute("SELECT * FROM T_Goods_Units")
    units = curUnits.fetchall()

    if request.method == 'POST':

        # Get User ID
        user_id = session['user_id']

        # Request Order Information Details
        order_id = request.form['orderId']
        pickup_date = request.form['pickupDate']

        if pickup_date is None:
            pickup_date = ""

        delivery_date = request.form['deliveryDate']

        if delivery_date is None:
            delivery_date = ""

        # Request Order PickUp/Delivery Address
        streetAddress = request.form['street']
        houseAddress = request.form['house']
        cityAddress = request.form['city']
        stateAddress = request.form['state']
        zipCode = request.form['zipCode']

        if "receiver" in request.form:
            receiverName = request.form['receiver']
        else:
            receiverName = None

        # Request Order Products
        sku = request.form.getlist('SKU[]')
        itemDesc = request.form.getlist('Good_Desc[]')
        unit = request.form.getlist('Unit[]')
        quantity = request.form.getlist('Quantity[]')
        int_numItems = len(sku)

        # Update Order Cursor
        update_cur = mysql.connection.cursor()
        
        #Execute Procedure to Delete an Order
        args = (order_id, receiverName, streetAddress, houseAddress, cityAddress, stateAddress, zipCode, pickup_date, delivery_date)
        update_cur.callproc("update_Order", args)
        
        # Close Connection
        update_cur.close()

        # Delete Order Goods Cursor
        delete_cur = mysql.connection.cursor()
        
        #Execute Procedure to Delete an Order
        args = (order_id,)
        delete_cur.callproc("cleanOrder_BeforeUpdate", args)
        
        # Close Connection
        delete_cur.close()

        # New Order Goods Cursor
        orderGoods_cur = mysql.connection.cursor()
    
        for x in range(0, int_numItems):
            _sku = sku[x]
            _itemDesc = itemDesc[x]
            _itemUnit = unit[x]
            _quantity = quantity[x]
            _GoodsArgs = (order_id, _sku, _itemDesc, _itemUnit, _quantity, user_id)
            # Insert Warehouse User Goodies and Goodies of the order in DB
            orderGoods_cur.callproc("insert_GoodsUser", _GoodsArgs)
        
        orderGoods_cur.close()

        #msg = 'The order has been updated successfully'
        #return render_template('UpdateOrder.html', order=order, goods=goods, states=states, units=units, msg=msg)

        flash('The order has been updated successfully', 'success')
        return redirect(url_for('UpdateOrderDetail', id=id))
        #return redirect(url_for('password_confirm', email=email))

    else:
        
        if result > 0:
            return render_template('UpdateOrder.html', order=order, goods=goods, states=states, units=units)
        else:
            error = 'Order ID was not found'
            return render_template('UpdateOrder.html', error=error, order=order)

    order_cursor.close()
    goods_cursor.close()
    curStates.close()
    curUnits.close()
    
    #return render_template('UpdateOrder.html')

@app.route('/AdminUsers', methods=['GET'])
@is_admin
def AdminUsers():
    if request.method == 'GET':
        # Create Cursor for getting Warematic System Users.
        crew_cursor = mysql.connection.cursor()

        # Create Cursor for getting states info.
        curProfiles = mysql.connection.cursor()

        # Get users orders information
        result = crew_cursor.execute("call get_WarematicCrew();")
        users = crew_cursor.fetchall()

        # Get States information
        curProfiles.execute("call get_WarehouseProfiles();")
        profiles = curProfiles.fetchall()

        if result > 0:
            return render_template('AdminUsers.html', users=users, profiles=profiles)
        else:
            warning = ' There is no system users created for this application'
            return render_template('AdminUsers.html', warning=warning)
        
        crew_cursor.close()
        curProfiles.close()
    
@app.route('/AddNewCrewUser', methods=['POST'])
@is_admin
def AddNewCrewUser():
    if request.method == 'POST':
        FirstName = request.form['firstName']
        LastName = request.form['lastName']
        Email = request.form['userEmail']
        UserPassword = sha256_crypt.encrypt(str(request.form['userPassword']))
        ProfileID = request.form['userProfileID']
        try:
            # Update Order Cursor
            insert_cur = mysql.connection.cursor()
        
            #Execute Procedure to Delete an Order
            args = (FirstName, LastName, Email, UserPassword, ProfileID)
            insert_cur.callproc("insert_WarematicCrewUser", args)
        
            # Close Connection
            insert_cur.close()

            msg = 'New Warematic Crew Member Added Succesfully'

            # Create Cursor for getting Warematic System Users.
            crew_cursor = mysql.connection.cursor()

            # Create Cursor for getting states info.
            curProfiles = mysql.connection.cursor()

            # Get users orders information
            result = crew_cursor.execute("call get_WarematicCrew();")
            users = crew_cursor.fetchall()

            # Get States information
            curProfiles.execute("call get_WarehouseProfiles();")
            profiles = curProfiles.fetchall()

            if result > 0:
                return render_template('AdminUsers.html', users=users, profiles=profiles, msg=msg)
            
            crew_cursor.close()
            curProfiles.close()

        except ValueError:
            print("System Error. MySql execution bug: insert_WarematicCrewUser")
    
@app.route('/EditCrewUser', methods=['POST'])
@is_admin
def EditCrewUser():
    if request.method == 'POST':
        UserID = request.form['userID']
        FirstName = request.form['firstName']
        LastName = request.form['lastName']
        Email = request.form['userEmail']
        ProfileID = request.form['userProfileID']
        try:
            # Update Order Cursor
            update_cur = mysql.connection.cursor()
        
            #Execute Procedure to Delete an Order
            args = (UserID, FirstName, LastName, Email, ProfileID)
            update_cur.callproc("update_WarematicCrewUser", args)
        
            # Close Connection
            update_cur.close()

            msg = 'Warematic Crew Member Updated Succesfully'

            # Create Cursor for getting Warematic System Users.
            crew_cursor = mysql.connection.cursor()

            # Create Cursor for getting states info.
            curProfiles = mysql.connection.cursor()

            # Get users orders information
            result = crew_cursor.execute("call get_WarematicCrew();")
            users = crew_cursor.fetchall()

            # Get States information
            curProfiles.execute("call get_WarehouseProfiles();")
            profiles = curProfiles.fetchall()

            if result > 0:
                return render_template('AdminUsers.html', users=users, profiles=profiles, msg=msg)
                
            crew_cursor.close()
            curProfiles.close()
            
        except ValueError:
            print("System Error. MySql execution bug: update_WarematicCrewUser")

# Update User Profile
@app.route('/GeneralUserProfile', methods=['GET', 'POST'])
@is_logged_in
def GeneralUserProfile():
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
        firstName = request.form['firstname']
        lastName = request.form['lastname']
        clientEmail = request.form['email']
        clientPhone = request.form['phone']
        street = request.form['street']
        house = request.form['house']
        city = request.form['city']
        state = request.form['state']
        zipCode = request.form['zipCode']
        try:
            # Update Order Cursor
            update_cur = mysql.connection.cursor()
        
            #Execute Procedure to Delete an Order
            args = (user_id, firstName, lastName, clientEmail, clientPhone, street, house, city, state, zipCode)
            update_cur.callproc("update_WarematicGeneralUser", args)
        
            # Close Connection
            update_cur.close()
            
            if result > 0:
                flash('User Profile Updated Succesfully', 'success')
                return redirect(url_for('GeneralUserProfile'))

        except ValueError:
            print("System Error. MySql execution bug: update_WarematicGeneralUser")
    else:
        if result > 0:
            return render_template('GeneralUserProfile.html', userInfo=userInfo, states=states)
        else:
            msg = 'No user information found'
            return render_template('GeneralUserProfile.html', msg=msg)

    # Close connection
    cur.close()
    curStates.close()

# Report 1 - View Warehouse Merchandise
@app.route('/WarehouseMerch_Report', methods=['GET', 'POST'])
@is_admin
def WarehouseMerch_Report():

     # Create Cursor for getting warehouse orders to process.
    merch_cursor = mysql.connection.cursor()

    # Get users orders information
    result = merch_cursor.execute("call report_WarehouseMerchandise();")
    products = merch_cursor.fetchall()

    if result > 0:
        return render_template('WareHouseGoods_Report.html', products=products)
    else:
        warning = ' There is no products storaged in the warehouse'
        return render_template('WareHouseGoods_Report.html', warning=warning)
        
    merch_cursor.close()

# Report 2 - View Active Clients
@app.route('/ActiveClients_Report', methods=['GET', 'POST'])
@is_admin
def ActiveClients_Report():

     # Create Cursor for getting warehouse orders to process.
    client_cursor = mysql.connection.cursor()

    # Get users orders information
    result = client_cursor.execute("call report_ActiveClients();")
    clients = client_cursor.fetchall()

    if result > 0:
        return render_template('ActiveClients_Report.html', clients=clients)
    else:
        warning = ' There is no products storaged in the warehouse'
        return render_template('ActiveClients_Report.html', warning=warning)
        
    client_cursor.close()

# Report 3
@app.route('/ActiveOrders_Statistic', methods=['GET', 'POST'])
@is_admin
def ActiveOrders_Statistic():
    # Create Cursor for getting warehouse orders to process.
    report_cursor = mysql.connection.cursor()

    # Get users orders information
    result = report_cursor.execute("call stat_numActive_Orders();")
    rows = report_cursor.fetchall()

    if result > 0:
        return render_template('ActiveOrders_Statistic.html', rows=rows)
    else:
        warning = ' There is no information to display'
        return render_template('ActiveOrders_Statistic.html', warning=warning)
        
    report_cursor.close()

@app.route('/visualize')
def visualize():
    
    fig,ax=plt.subplots(figsize=(5,5))
    sns.set()
    sns.set_style(style="darkgrid")

    mysql_cn = MySQLdb.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='warematic_db')
    df_mysql = pd.read_sql('SELECT IF(ID_Order_Type = 1, "Pick Up", "Delivery") as Order_Type, COUNT(ID_Order_Type) as Num_Orders FROM T_Orders WHERE (ID_Order_Status <> 4 AND ID_Order_Status <> 5) AND Order_Active = 1 GROUP BY ID_Order_TYPE;', con=mysql_cn)
    sns.barplot(data = df_mysql
            ,x = 'Order_Type'
            ,y = 'Num_Orders'
            ,color = 'cyan'
            ,ci = None
            ,palette="nipy_spectral"
            )

    #fig1 = plt.figure()
    #ax1 = fig1.add_axes([0,0,1,1])
    #langs = df_mysql['Order_Type']
    #students = df_mysql['Num_Orders']
    #ax1.bar(langs,students, label='Weekends Nights')
    #plt.show()

    mysql_cn.close()
    #canvas = FigureCanvas(fig)
    img = io.BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='img/png')

# Report 4
@app.route('/ActiveOrders_Status_Statistic', methods=['GET', 'POST'])
@is_admin
def ActiveOrders_Status_Statistic():
    # Create Cursor for getting warehouse orders to process.
    report_cursor = mysql.connection.cursor()

    # Get users orders information
    result = report_cursor.execute("call stat_numActive_Orders_byStatus();")
    rows = report_cursor.fetchall()

    if result > 0:
        return render_template('ActiveOrders_Status_Statistic.html', rows=rows)
    else:
        warning = ' There is no products storaged in the warehouse'
        return render_template('ActiveOrders_Status_Statistic.html', warning=warning)
        
    report_cursor.close()

@app.route('/visualize_numOrders_by_type')
def visualize_numOrders_by_type():
    
    fig,ax=plt.subplots(figsize=(5,5))
    sns.set()
    sns.set_style(style="darkgrid")

    mysql_cn = MySQLdb.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='warematic_db')

    query = 'SELECT IF(ID_Order_Type = 1, "Pick Up", "Delivery") as Order_Type, '
    query = query + 'CASE '
    query = query + "   WHEN ID_Order_Status = 1 THEN 'In Process' "
    query = query + "   WHEN ID_Order_Status = 2 THEN 'Processed' "
    query = query + "   ELSE 'In Transit' "
    query = query + 'END as Status, '
    query = query + 'COUNT(ID_Order_Status) as Num_Orders '
    query = query + 'FROM T_Orders '
    query = query + 'WHERE Order_Active = 1 '
    query = query + 'AND (ID_Order_Status <> 4 AND ID_Order_Status <> 5) '
    query = query + 'GROUP BY Order_Type, ID_Order_Status '
    query = query + 'ORDER BY ID_Order_Status; '

    df_mysql = pd.read_sql(query, con=mysql_cn)
    sns.barplot(data = df_mysql
            ,x = 'Status'
            ,y = 'Num_Orders'
            ,hue = 'Order_Type'
            ,color = 'cyan'
            ,ci = None
            ,palette="mako_r"
            )
    mysql_cn.close()
    #canvas = FigureCanvas(fig2)
    img = io.BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='img/png')

# Report 5
@app.route('/WarehouseCapacity_Statistic', methods=['GET', 'POST'])
@is_admin
def WarehouseCapacity_Statistic():
    return render_template('WarehouseCapacity_Statistic.html')

@app.route('/visualize_warehouseCapacity')
def visualize_warehouseCapacity():
    
    mysql_cn = MySQLdb.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='warematic_db')

    query = 'SELECT Full_Slot, COUNT(Full_Slot) as Num_Full, 91 - COUNT(Full_Slot) as Empty_Slots '
    query = query + 'FROM v_slots_occupied '
    query = query + 'WHERE Full_Slot = 1 '
    query = query + 'GROUP BY Full_Slot; '

    df_mysql = pd.read_sql(query, con=mysql_cn)

    labels = 'Full Slots %', 'Empty Slots %'
    sizes = [ df_mysql['Num_Full'], df_mysql['Empty_Slots'] ]
    
    # Getting the highest index of the highest amount of nights
    maxSize = np.argmax(sizes)
    
    if (maxSize == 0):
        explode = (0.1, 0) # only "explode" the 1st slice
    else:
        explode = (0, 0.1) # only "explode" the 2nd slice

    fig,ax=plt.subplots(figsize=(5,5))
    ax.pie(sizes, explode=explode, labels=labels, autopct='%1.1f%%',
            shadow=True, startangle=90)
    ax.set_title('Warehouse Capacity', fontsize=14)
    ax.axis('equal') 
    
    mysql_cn.close()
    img = io.BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='img/png')

# Report 6
@app.route('/Orders_GeoDistribution_Statistic', methods=['GET', 'POST'])
@is_admin
def Orders_GeoDistribution_Statistic():
    # Create Cursor for getting warehouse orders to process.
    report_cursor = mysql.connection.cursor()

    # Get users orders information
    result = report_cursor.execute("call report_Orders_GeoDistribution();")
    rows = report_cursor.fetchall()

    if result > 0:
        return render_template('Orders_GeoDistribution_Statistic.html', rows=rows)
    else:
        warning = ' There is no information to display'
        return render_template('Orders_GeoDistribution_Statistic.html', warning=warning)
        
    report_cursor.close()

@app.route('/visualize_Orders_GeoDistribution')
def visualize_Orders_GeoDistribution():
    
    fig,ax=plt.subplots(figsize=(7,5))
    sns.set()
    sns.set_style(style="darkgrid")

    mysql_cn = MySQLdb.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='warematic_db')
    
    query = 'SELECT City, COUNT(City) as Num_Orders '
    query = query + 'FROM T_Orders '
    query = query + 'GROUP BY City '
    query = query + 'ORDER BY Num_Orders desc;'
    
    df_mysql = pd.read_sql(query, con=mysql_cn)
    
    sns.barplot(data = df_mysql
            ,x = 'Num_Orders'
            ,y = 'City'
            ,color = 'cyan'
            ,ci = None
            ,palette="mako_r"
            ,orient='h'
            )

    mysql_cn.close()
    #canvas = FigureCanvas(fig)
    img = io.BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='img/png')



if __name__ == '__main__':
    app.secret_key='secret1234'
    app.run(port = 3000, debug = True)