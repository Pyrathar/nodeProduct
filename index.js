var express = require('express');
var app = express();
const productController = require('./controllers/productController');
a
app.get('/products', async function (req, res) {
    const products = await productController.getProducts();
    res.send(products);
});

app.get('/products/:code', async function (req, res) {
    const { code } = req.params;
    const products = await productController.getProductsByType(code);
    res.send(products);
 });
 

var server = app.listen(8081, function () {
   var host = server.address().address;
   var port = server.address().port;
   
   console.log("Example app listening at http://%s:%s", host, port);
});
