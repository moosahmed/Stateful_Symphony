var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index');
});

router.get('/slides', function(req, res, next) {
  res.redirect('https://docs.google.com/presentation/d/1gGlgV1YE199ZMC27SL9aNVAoPzZZmusbKoBV8IPybpw/edit?usp=sharing');
});

module.exports = router;
