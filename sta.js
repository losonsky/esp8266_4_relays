var cfgstassid = "";
var cfgstapwd = "";
var cfgaccessip = "";

function AjaxCFG(){
var ssid=document.getElementById("cfgstassid");
var pwd=document.getElementById("cfgstapwd");
var ip=document.getElementById("cfgaccessip");
ssid.value=decodeURIComponent(cfgstassid);
pwd.value=decodeURIComponent(cfgstapwd);
ip.innerHTML=cfgaccessip;
}

function AjaxSTATUS(){
var AR=new XMLHttpRequest();
AR.onreadystatechange=function(){
if(AR.readyState == 4 && AR.status == 200){
eval(AR.responseText);
AjaxCFG();
}
}
AR.open("GET", "cfg.html?STA=STATUS", true);
AR.timeout = 200;
AR.send();
}

function AjaxSTATUS2(){
var ip=document.getElementById("cfgaccessip");
var AR=new XMLHttpRequest();
AR.onreadystatechange=function(){
if(AR.readyState == 4 && AR.status == 200){
eval(AR.responseText);
ip.innerHTML=cfgaccessip;
}
}
AR.open("GET", "cfg.html?AIP=STATUS", true);
AR.timeout = 300;
AR.send();
setTimeout(AjaxSTATUS2, 1000);
}

function AjaxSUBMIT(){
var ssid=document.getElementById("cfgstassid").value;
var pwd=document.getElementById("cfgstapwd").value;
var AR=new XMLHttpRequest();
AR.open("GET", "cfg.html?cfgstassid=" + encodeURIComponent(ssid) + "&cfgstapwd=" + encodeURIComponent(pwd), true);
AR.timeout = 300;
AR.send();
alert("Saved.");
}

AjaxSTATUS();
AjaxSTATUS2();
