var SR1 = 0;
var SR2 = 0;
var SR3 = 0;
var SR4 = 0;

function Draw(){
for (i = 1; i < 5; i ++){
var div = document.getElementById("sr"+i);
var of = "";
var un = "";
var on = "";

if(this["SR" + i] == 0) of = " checked=\"\"";
if(this["SR" + i] == 1) un = " checked=\"\"";
if(this["SR" + i] == 2) on = " checked=\"\"";

div.innerHTML="\
<input type=\"radio\" name=\"sr"+i+"\""+of+" value=\"0\">\
off\
<input type=\"radio\" name=\"sr"+i+"\""+un+" value=\"1\">\
unchanged\
<input type=\"radio\" name=\"sr"+i+"\""+on+" value=\"2\">\
on<br>";
}
}

function AjaxSUBMIT(){
var AR=new XMLHttpRequest();
for (i = 1; i < 5; i ++){
 var RB=document.getElementsByName("sr" + i);
 for(j = 0; j < RB.length; j ++){
  var e=RB[j];
  if(e.checked){
   this["SR" + i] = e.value;
   break;
  }
 }
}
AR.open("GET", "cfg.html?SR1="+SR1+"&SR2="+SR2+"&SR3="+SR3+"&SR4="+SR4, true);
AR.timeout = 300;
AR.send();
alert("Saved.");
}

function AjaxSTATUS(){
var AR=new XMLHttpRequest();
AR.onreadystatechange=function(){
if(AR.readyState == 4 && AR.status == 200){
eval(AR.responseText);
Draw();
}
}
AR.open("GET", "cfg.html?RLS=STATUS", true);
AR.timeout = 300;
AR.send();
}

AjaxSTATUS();
