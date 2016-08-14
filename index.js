var REL1="";
var REL2="";
var REL3="";
var REL4="";

function AjaxColor(){
var r1=document.getElementById("REL1");
var r2=document.getElementById("REL2");
var r3=document.getElementById("REL3");
var r4=document.getElementById("REL4");

if(REL1 == "OFF"){
r1.innerHTML="OFF";
r1.style.color="#3F1F1F";
}else{
r1.innerHTML="ON";
r1.style.color="#FF0000";
}

if(REL2 == "OFF"){
r2.innerHTML="OFF";
r2.style.color="#3F3F1F";
}else{
r2.innerHTML="ON";
r2.style.color="#BFBF00";
}

if(REL3 == "OFF"){
r3.innerHTML="OFF";
r3.style.color="#1F3F1F";
}else{
r3.innerHTML="ON";
r3.style.color="#00FF00";
}

if(REL4 == "OFF"){
r4.innerHTML="OFF";
r4.style.color="#1F1F3F";
}else{
r4.innerHTML="ON";
r4.style.color="#0000FF";
}
}

function AjaxREL(relay){
var AR=new XMLHttpRequest();
var r=document.getElementById(relay);
r.innerHTML="WAIT";
r.style.color="#AFAFAF";
if(this[relay] == "ON"){
this[relay]="OFF";
}else{
this[relay]="ON";
}
AR.open("GET", "cfg.html?" + relay + "=" + this[relay], true);
AR.timeout = 300;
AR.send();
}

function AjaxLOOP(){
AjaxSTATUS();
setTimeout(AjaxLOOP, 1000);
}

function AjaxSTATUS(){
var AR=new XMLHttpRequest();
AR.onreadystatechange=function(){
if(AR.readyState == 4 && AR.status == 200){
eval(AR.responseText);
AjaxColor();
}
}
AR.open("GET", "cfg.html?REL=STATUS", true);
AR.timeout = 300;
AR.send();
}

AjaxLOOP();
