const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
app.use(bodyParser.json());
app.use(cors());

mongoose.connect('mongodb://localhost:27017/drink_shop');

// Schemas
const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    phone: { type: String, required: true },
    address: String,
    role: { type: String, default: 'customer' }
});

const productSchema = new mongoose.Schema({
    name: { type: String, required: true },
    description: String,
    price: { type: Number, required: true },
    category: String,
    image: String
});

const orderSchema = new mongoose.Schema({
    customer_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    order_date: { type: Date, default: Date.now },
    total_amount: { type: Number, required: true },
    status: { type: String, default: 'Processing' },
    orderDetails: [{ type: mongoose.Schema.Types.ObjectId, ref: 'OrderDetail' }]
});

const orderDetailSchema = new mongoose.Schema({
    order_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    product_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    quantity: { type: Number, required: true },
    price: { type: Number, required: true }
});

const categorySchema = new mongoose.Schema({
    name: { type: String, required: true }
});

const reviewSchema = new mongoose.Schema({
    product_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    customer_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    rating: { type: Number, required: true },
    comment: String,
    date: { type: Date, default: Date.now }
});

const discountCodeSchema = new mongoose.Schema({
    code: { type: String, required: true },
    discount_percentage: { type: Number, required: true },
    expiry_date: { type: Date, required: true }
});

// Models
const User = mongoose.model('User', userSchema);
const Product = mongoose.model('Product', productSchema);
const Order = mongoose.model('Order', orderSchema);
const OrderDetail = mongoose.model('OrderDetail', orderDetailSchema);
const Category = mongoose.model('Category', categorySchema);
const Review = mongoose.model('Review', reviewSchema);
const DiscountCode = mongoose.model('DiscountCode', discountCodeSchema);

// Middleware xác thực

const authMiddleware = (requiredRole) => {
    return (req, res, next) => {
        const token = req.header('Authorization').replace('Bearer ', '');
        if (!token) {
            return res.status(401).send('Access denied. No token provided.');
        }

        try {
            const decoded = jwt.verify(token, 'your_jwt_secret');
            req.user = decoded;

            // Kiểm tra vai trò người dùng
            if (requiredRole && req.user.role !== requiredRole) {
                return res.status(403).send('Access denied. Insufficient permissions.');
            }

            next();
        } catch (ex) {
            res.status(400).send('Invalid token.');
        }
    };
};

// Endpoint đăng ký
app.post('/register', async(req, res) => {
    const { name, email, password, phone, address } = req.body;

    // Kiểm tra định dạng email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return res.status(400).send('Invalid email format');
    }

    // Kiểm tra định dạng số điện thoại
    const phoneRegex = /^[0-9]{10}$/; // Ví dụ: Số điện thoại phải có 10 chữ số
    if (!phoneRegex.test(phone)) {
        return res.status(400).send('Invalid phone number format');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ name, email, password: hashedPassword, phone, address });

    try {
        await newUser.save();
        res.status(201).send('User registered');
    } catch (error) {
        if (error.code === 11000) { // Mã lỗi MongoDB cho lỗi trùng lặp
            res.status(400).send('Email already exists');
        } else {
            res.status(400).send('Error registering user');
        }
    }
});

// Endpoint đăng nhập
app.post('/login', async(req, res) => {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'User not found' });

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) return res.status(400).json({ message: 'Invalid password' });

    const token = jwt.sign({ id: user._id, role: user.role }, 'your_jwt_secret'); // Thêm role vào token
    res.send({ token, role: user.role }); // Trả về token và role
});

// Endpoint thêm sản phẩm yêu cầu xác thực admin
app.post('/products', authMiddleware('admin'), async(req, res) => {
    const { name, description, price, category, image } = req.body;

    const newProduct = new Product({ name, description, price, category, image });

    try {
        await newProduct.save();
        res.status(201).send('Product added');
    } catch (error) {
        res.status(400).send('Error adding product');
    }
});

// Endpoint lấy danh sách sản phẩm
app.get('/products', async(req, res) => {
    try {
        const products = await Product.find();
        res.send(products);
    } catch (error) {
        res.status(400).send('Error fetching products');
    }
});

// Endpoint tạo đơn hàng yêu cầu xác thực
app.post('/orders', authMiddleware(), async(req, res) => {
    const { customer_id, total_amount, status, orderDetails } = req.body;

    const newOrder = new Order({ customer_id, total_amount, status });

    try {
        const savedOrder = await newOrder.save();
        const orderDetailIds = [];

        for (const detail of orderDetails) {
            const newOrderDetail = new OrderDetail({
                order_id: savedOrder._id,
                product_id: detail.product_id,
                quantity: detail.quantity,
                price: detail.price
            });
            const savedOrderDetail = await newOrderDetail.save();
            orderDetailIds.push(savedOrderDetail._id);
        }

        savedOrder.orderDetails = orderDetailIds;
        await savedOrder.save();

        res.status(201).send('Order placed');
    } catch (error) {
        res.status(400).send('Error placing order');
    }
});

// Endpoint cập nhật trạng thái đơn hàng yêu cầu xác thực admin
app.patch('/orders/:id/status', authMiddleware('admin'), async(req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    try {
        const order = await Order.findByIdAndUpdate(id, { status }, { new: true });
        res.send(order);
    } catch (error) {
        res.status(400).send('Error updating order status');
    }
});

// Endpoint lấy danh sách đơn hàng yêu cầu xác thực admin
app.get('/orders', authMiddleware('admin'), async(req, res) => {
    try {
        const orders = await Order.find().populate('customer_id').populate({
            path: 'orderDetails',
            populate: {
                path: 'product_id'
            }
        });
        res.send(orders);
    } catch (error) {
        res.status(400).send('Error fetching orders');
    }
});

// Endpoint thêm danh mục yêu cầu xác thực admin
app.post('/categories', authMiddleware('admin'), async(req, res) => {
    const { name } = req.body;

    const newCategory = new Category({ name });

    try {
        await newCategory.save();
        res.status(201).send('Category added');
    } catch (error) {
        res.status(400).send('Error adding category');
    }
});

// Endpoint lấy danh sách danh mục
app.get('/categories', async(req, res) => {
    try {
        const categories = await Category.find();
        res.send(categories);
    } catch (error) {
        res.status(400).send('Error fetching categories');
    }
});

// Endpoint thêm đánh giá yêu cầu xác thực
app.post('/reviews', authMiddleware(), async(req, res) => {
    const { product_id, customer_id, rating, comment } = req.body;

    const newReview = new Review({ product_id, customer_id, rating, comment });

    try {
        await newReview.save();
        res.status(201).send('Review added');
    } catch (error) {
        res.status(400).send('Error adding review');
    }
});

// Endpoint lấy đánh giá sản phẩm
app.get('/reviews', async(req, res) => {
    try {
        const reviews = await Review.find().populate('product_id').populate('customer_id');
        res.send(reviews);
    } catch (error) {
        res.status(400).send('Error fetching reviews');
    }
});

// Endpoint thêm mã giảm giá yêu cầu xác thực admin
app.post('/discount_codes', authMiddleware('admin'), async(req, res) => {
    const { code, discount_percentage, expiry_date } = req.body;

    const newDiscountCode = new DiscountCode({ code, discount_percentage, expiry_date });

    try {
        await newDiscountCode.save();
        res.status(201).send('Discount code added');
    } catch (error) {
        res.status(400).send('Error adding discount code');
    }
});
// Endpoint lấy danh sách mã giảm giá yêu cầu xác thực admin
app.get('/discount_codes', authMiddleware('admin'), async(req, res) => {
    try {
        const discountCodes = await DiscountCode.find();
        res.send(discountCodes);
    } catch (error) {
        res.status(400).send('Error fetching discount codes');
    }
});
// Endpoint lấy danh sách người dùng
app.get('/users', authMiddleware('admin'), async(req, res) => {
    try {
        const users = await User.find();
        res.json(users);
    } catch (error) {
        res.status(400).send('Error fetching users');
    }
});
// Khởi động server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});