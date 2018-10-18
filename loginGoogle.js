var fs = require("fs");
//var http = require('http');
//var utils = require('utils');
var searchString = "";
var casper = require('casper').create();
url = 'https://accounts.google.com/ServiceLogin?passive=1209600&continue=https%3A%2F%2Faccounts.google.com%2FManageAccount&followup=https%3A%2F%2Faccounts.google.com%2FManageAccount&flowName=GlifWebSignIn&flowEntry=ServiceLogin&nojavascript=1#identifier';
casper.start(url, function() {

// GET website status code and print it
    var res = this.status(false);
    var stat = res.currentHTTPStatus;
          switch(stat) {
              case 200: var statusStyle = { fg: 'green', bold: true }; break;
              case 404: var statusStyle = { fg: 'red', bold: true }; break;
              default: var statusStyle = { fg: 'magenta', bold: true }; break;
          }
          this.echo(this.colorizer.format(stat, statusStyle) + ' ' + url);
// --------------------------------------


  this.fillSelectors('form#gaia_loginform', {
    'input[name="Email"]': 'fekete.jozsef.joe@gmail.com',
  }); //Fills the email box with email
  this.click("#next");

  this.wait(500, function() { //Wait for next page to load
    this.waitForSelector("#Passwd", //Wait for password box
      function success() {
        console.log("SUCCESS...");
        this.fillSelectors('form#gaia_loginform', {
          'input[name="Passwd"]': 'asdasdasd',
        }); //Fill password box with PASSWORD
        this.click("#signIn"); //Click sign in button
        this.wait(500, function() {}); //Wait for it fully sigin
        casper.thenOpen('http://utility.google.com/', function() {
            this.wait(2000, function() {
              this.echo("download...");
              searchString = this.fetchText(".ZrQ9j");
              if (searchString==""){
              this.echo("ERROR, searchString not found!!!");
              }
              else{
              this.echo("SUCCESS, searchString was found!!!");
              }
              this.echo("searchString = " + searchString);
              fs.write("media/gugli.html", this.getHTML(), "w");
                this.capture('media/status.png', undefined, {
                    format: 'png',
                    quality: 100
                });
            });
        });
      },
      function fail() {
        console.log("FAIL...");
      }
    );
  });
});
casper.run();
