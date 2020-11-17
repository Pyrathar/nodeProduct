const axios = require('axios');
async function getProducts() {
    const voice = await getProduct('https://a23hnpdl9j.execute-api.eu-north-1.amazonaws.com/os-test/get-mobile-voice');
    const broadband = await getProduct('https://a23hnpdl9j.execute-api.eu-north-1.amazonaws.com/os-test/get-broadband-broadband');
    const allProducts = joinAdditionalProducts(voice.concat(broadband));
    const simplifiedStructure = [];
    allProducts.map((product) => { 
        if (product.productCode && product.productName) 
        simplifiedStructure.push({ name: product.productName, code: product.productCode}) 
    });
    return simplifiedStructure;
}

async function getProductsByType(code) {
    const voice = await getProduct('https://a23hnpdl9j.execute-api.eu-north-1.amazonaws.com/os-test/get-mobile-voice');
    const broadband = await getProduct('https://a23hnpdl9j.execute-api.eu-north-1.amazonaws.com/os-test/get-mobile-broadband');
    const allProducts = joinAdditionalProducts(voice.concat(broadband));
    const filteredProducts = allProducts.filter(product => product.productCode === code);
    return filteredProducts;
}

async function getProduct(url) {
    try {
        const response = await axios.get(url);
        return response.data.product;
    } catch (e) {
        console.log(e);
    }
}

//will add the additional products into one
function joinAdditionalProducts(listOfProducts) {
    const allProducts = [];
    listOfProducts.map((products) => {
        const { additionalProducts, ...product } = products;
        allProducts.push(additionalProducts);
        allProducts.push(product);
    });
    return allProducts.flat();
}

module.exports = {
    getProducts,
    getProductsByType
};