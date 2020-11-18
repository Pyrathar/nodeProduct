var express = require('express');
var app = express();
var cache = require('memory-cache');
const productController = require('./controllers/productController');

let memCache = new cache.Cache();
    let cacheMiddleware = (duration) => {
        return (req, res, next) => {
            let key =  '__express__' + req.originalUrl || req.url
            let cacheContent = memCache.get(key);
            if(cacheContent){
                res.send( cacheContent );
                return
            }else{
                res.sendResponse = res.send
                res.send = (body) => {
                    memCache.put(key,body,duration*1000);
                    res.sendResponse(body)
                }
                next()
            }
        }
    }


app.get('/products',cacheMiddleware(10), async function (req, res) {
    const products = await productController.getProducts();
    res.send(products);
});

app.get('/products/:code', cacheMiddleware(10), async function (req, res) {
    const { code } = req.params;
    const products = await productController.getProductsByType(code);
    res.send(products);
 });
 

var server = app.listen(8081, function () {
   var host = server.address().address;
   var port = server.address().port;
   
   console.log("Example app listening at http://%s:%s", host, port);
});
