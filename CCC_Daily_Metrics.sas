/*****************/
/* Program: CCC_Daily_Metrics
/* Program location: C:\Users\natarajanm2\OneDrive - National Institutes of Health\desktop\BQ Testing
/* Updated: 9/20/22
/* SAS Enterprise Guide Version 7.15
/* Author: Madhuri Natarajan
/* Study Name: Connect for Cancer Prevention Study
/*
/* 
/*
/* Description: This is the SAS code for the CCC Daily Metrics. Run this after the data processing code.
/*****************/

*Keeping Active and Passive Only;
DATA Work.CONCEPT_IDS;
SET Work.CONCEPT_IDS;
IF RcrtSI_RecruitType_v1r0 NE 180583933 THEN OUTPUT; 
RUN;

options PRINTERPATH=PDF;
ods pdf file='C:\Users\natarajanm2\Desktop\CCC_Daily_Metrics.pdf' NOGTITLE
NOGFOOTNOTE startpage=never style=PEARL;
Options nodate nonumber;
/*options bottommargin=0.25in topmargin=0.25in;*/
*Adding Page Numbers to Bottom Right of Page;
ods escapechar="^";
footnote j=right "^{thispage}";
RUN;

*Recruitment Type & Title for Report;
data _null_;
today =
trim(left(put(date(),worddate18.)));
call symput('dtnull',today);
run;

PROC PRINT noobs DATA=recruittypetotal label;
VAR RcrtSI_RecruitType_v1r0 COUNT;
/*Title1 'CCC Daily Metrics – July 21, 2022'*/
Title1 height=20pt "CCC Daily Metrics – &dtnull";
Title2 " ";
Title3 " ";
Title4 " ";
Title5 " ";
Title6 " ";
Title7 "All Records in Connect";
RUN;

/*JING'S CODE START'S HERE*/
ods pdf style=HTMLBLUE;
proc sgplot data=recru_count1 DATTRMAP=DAttrs;
title "Cumulative Status of Recruitment (Active and Passive)";
/*styleattrs datacolors=(lightblue red green orange blue purple brown pink yellow aquamarine chartreuse khaki teal rose);*/
vbar stage/response=count group=RcrtES_Site_v1r0 ATTRID=ID stat=sum groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold) ; 
*xaxis display = (nolabel);
yaxis grid label="# Participants";
where recr_Process_v1r0=353358909;
format stage WorkFlowFmtJW. RcrtES_Site_v1r0 SiteFmtJW. value $SiteFmt31.;
where RcrtES_Site_v1r0 NE . and stage>0;
run;

data up_type_verif; set up_type_verif; Participants =count;
label participants = "# Participants";
run;

proc sgplot data=UP_type_verif dattrmap=DAttrs;
title "Passive Recruits Verification Status among those with Profile Completed";
vbar RcrtV_Verification_v1r0/response=participants group=RcrtES_Site_v1r0 ATTRID=ID stat=sum  groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold); 
xaxis display = all values=(160161595 197316935 219863910 875007964 922622075);
yaxis grid label="# Participants";
/*where recr_Process_v1r0=353358909 or stage=0;
format stage WorkFlowFmtJW.;*/
where RcrtSI_RecruitType_v1r0=854703046;
informat RcrtES_Site_v1r0 SiteFmtJW. ;
run;

proc sgplot data=UP_type_verif DATTRMAP=DAttrs ;
title "Active Recruits Verification Status among those with Profile Completed";
vbar RcrtV_Verification_v1r0/response=participants group=RcrtES_Site_v1r0 ATTRID=ID stat=sum  groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold); 
xaxis display = all values=(160161595 197316935 219863910 875007964 922622075);
yaxis grid label="# Participants";
/*where recr_Process_v1r0=353358909 or stage=0;
format stage WorkFlowFmtJW.;*/
where RcrtSI_RecruitType_v1r0^=854703046;
run;


proc freq data=recruit_proces; tables RcrtES_Site_v1r0 * RcrtSI_RecruitType_v1r0*Rcrt_Verified_v1r0/list missing TOTPCT OUTPCT noprint out=UP_type_verified;
where RcrtUP_Submitted_v1r0=353358909;
run;

**stack;
proc freq data=recruit_proces; tables RcrtES_Site_v1r0 *RcrtSI_Age_v1r0/list missing TOTPCT OUTPCT noprint out=Age_verified;
where Rcrt_Verified_v1r0=353358909;
run;
proc sgplot data=Age_verified DATTRMAP=DAttrs;
title "Age of Verified Participants";
vbar RcrtSI_Age_v1r0/response=count group=RcrtES_Site_v1r0 ATTRID=ID stat=sum  groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold); 
xaxis display = all  values=("124276120" "450985724" "363147933" "636706443" "771230670");
yaxis grid label="# Participants";
/*where recr_Process_v1r0=353358909 or stage=0;
format stage WorkFlowFmtJW.;*/
run;

***for sex;

proc freq data=recruit_proces; tables RcrtES_Site_v1r0 *RcrtAll_Sex_v1r0/list missing TOTPCT OUTPCT noprint out=Sex_Site_verified;
where Rcrt_Verified_v1r0=353358909;
run;

proc sgplot data=Sex_site_verified DATTRMAP=DAttrs;
title "Sex of Verified Participants";
vbar RcrtAll_Sex_v1r0/response=count group=RcrtES_Site_v1r0 ATTRID=ID stat=sum groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold); 
*xaxis display = (nolabel);
yaxis grid label="# Participants";
/*where recr_Process_v1r0=353358909 or stage=0;
format stage WorkFlowFmtJW.;*/
run;


/*PROC SGRENDER DATA =recruit_proces
TEMPLATE = pie;
format RcrtES_Site_v1r0 SiteFmtJW. RcrtAll_Race_v1r0 SiteRaceEthnFmtJW.;
where Rcrt_Verified_v1r0=353358909;
RUN;
*/
***for race;
proc freq data=recruit_proces; tables RcrtES_Site_v1r0 *RcrtAll_Race_v1r0/list missing TOTPCT OUTPCT noprint out=Race_verified;
where Rcrt_Verified_v1r0=353358909;
run;
***stack plot;
proc sgplot data=Race_verified DATTRMAP=DAttrs;
title "Race/Ethnicity of Verified Participants";
vbar RcrtAll_Race_v1r0/response=count group=RcrtES_Site_v1r0  ATTRID=ID stat=sum groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold); 
*xaxis display = (nolabel);
yaxis grid label="# Participants";
/*where recr_Process_v1r0=353358909 or stage=0;
format stage WorkFlowFmtJW.;*/
run;


***stack for complete survey, and SSN;
proc freq data=recruit_proces; tables RcrtES_Site_v1r0 * RcrtSI_RecruitType_v1r0*ComplIntlSrv/list missing TOTPCT OUTPCT noprint out=IntlSrv_type_verified;
where Rcrt_Verified_v1r0=353358909;
run;

proc sgplot data=IntlSrv_type_verified DATTRMAP=DAttrs;
title "Completion of Initial Survey among Verified Participants";
vbar ComplIntlSrv/response=count group=RcrtES_Site_v1r0 ATTRID=ID stat=sum  groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold); 
*xaxis display = (nolabel);
yaxis grid label="# Participants";
/*where recr_Process_v1r0=353358909 or stage=0;
format stage WorkFlowFmtJW.;*/
run;

DATA recruit_proces;
SET recruit_proces;
IF SSNPieChart = 1 THEN SSNPieChartPlot = "0 Digits";
ELSE IF SSNPieChart = 2 THEN SSNPieChartPlot = "Partial Digits";
ELSE IF SSNPieCHart = 3 THEN SSNPieChartPlot = "Full Digits";
RUN;

proc freq data=recruit_proces; tables RcrtES_Site_v1r0 * RcrtSI_RecruitType_v1r0*SSNPieChartPlot/list missing TOTPCT OUTPCT noprint out=SrvSSN_type3_verified;
where Rcrt_Verified_v1r0=353358909;
run;
proc sgplot data=SrvSSN_type3_verified DATTRMAP=DAttrs;
title "Completion of SSN among Verified Participants";
vbar SSNPieChartPlot/response=count group=RcrtES_Site_v1r0 ATTRID=RcrtES_Site_v1r0 stat=sum groupdisplay=stack seglabel
datalabel datalabelattrs=(weight=bold);
*xaxis display = (nolabel);
yaxis grid label="# Participants";*/
/*where recr_Process_v1r0=353358909 or stage=0;
format stage WorkFlowFmt.;
run;

ods graphics off;

/*TABLES START HERE- MADHURI'S CODE*/
*Creating 0/1 variables for cumulative status tables;
data concept_ids;
set concept_ids;
if RcrtSI_SignedIn_v1r0 = 353358909 then signedIn=1; else signedin=0;
if RcrtCS_Consented_v1r0 = 353358909 then consented=1; else consented=0;
if RcrtUP_Submitted_v1r0 = 353358909 then submitted=1; else submitted=0;
Label signedIn = "Signed In"
	  consented = "Consented"
	  submitted= "User Profile Submitted";
run;

data concept_ids;
set concept_ids;
if RcrtSI_RecruitType_v1r0 = 486306141 then recruittype = 1;
else if RcrtSI_recruitType_v1r0 = 854703046 then recruittype = 1;
else recruittype = 0;
RUN;

*Creating character variable for site for tables;
data concept_ids;
length sitechar $300;
set concept_ids;
IF RcrtES_Site_v1r0 = 531629870 THEN sitechar= "HealthPartners";
ELSE IF RcrtES_Site_v1r0 = 657167265 THEN sitechar = "Sanford Health";
ELSE IF RcrtES_Site_v1r0 = 303349821 THEN sitechar = "Marshfield Clinic Health System";
ELSE IF RcrtES_Site_v1r0 = 125001209 THEN sitechar = "Kaiser Permanente Colorado";
ELSE IF RcrtES_Site_v1r0 = 327912200 THEN sitechar = "Kaiser Permanente Georgia";
ELSE IF RcrtES_Site_v1r0 = 300267574 THEN sitechar = "Kaiser Permanente Hawaii";
ELSE IF RcrtES_Site_v1r0 = 452412599 THEN sitechar = "Kaiser Permanente Northwest";
ELSE IF RcrtES_Site_v1r0 = 548392715 THEN sitechar = "Henry Ford Health System";
ELSE IF RcrtES_Site_v1r0 = 809703864 THEN sitechar = "University of Chicago Medicine";
*IF RcrtES_Site_v1r0 = 517700004 THEN OUTPUT; /*National Cancer Institute*/
*IF RcrtES_Site_v1r0 = 13 THEN OUTPUT; /*National Cancer Institute*/
ELSE IF RcrtES_Site_v1r0 = 181769837 THEN sitechar = "Other";
LABEL sitechar = "Site";
RUN;

*Creating reverse sign-in variable for current status in workflow tables (for never signed in);
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_SignedIn_v1r0 = 104430631 THEN SignInReverse = 1;
ELSE SignInReverse = 0;
RUN;

/*Cumulative Status Tables;*/

/*proc tabulate data=Concept_IDs;
class RcrtES_Site_v1r0;
var signedin consented submitted VerificationCompleteNum Verifiedbin;
table RcrtES_Site_v1r0 ALL='Total',
(signedin consented)*(sum='N' pctsum<signedin>='%')
submitted*(sum='N' pctsum<consented>='%') 
VerificationCompleteNum*(sum='N' pctsum<submitted>='%')
Verifiedbin*(sum='N' pctsum<VerificationCompleteNum>='%'); 
run;*/

*Cumulative Status Total Table;
ods pdf startpage=yes style=PEARL;
Title Cumulative Status Total; 
proc report data=concept_ids;
column sitechar
recruittype
SignedIn pct1 comb1 
Consented pct2 comb2 
Submitted pct3 comb3 
VerificationCompleteNum pct4 comb4
Verifiedbin pct5 comb5;
define sitechar / group center;
define recruittype / sum 'Total Recruits' style(column)=[cellwidth=0.95in] center;
define signedin / sum noprint center;
define pct1 / computed format=percent8.1 noprint center;
define comb1 / computed format=$20. 'Signed In' center;
define consented / sum noprint center;
define pct2 / computed format=percent8.1 noprint center;
define comb2 / computed format=$20. 'Consented' center;
define submitted / sum noprint center;
define pct3 / computed format=percent8.1 noprint center;
define comb3 / computed format=$20. 'User Profile Submitted' center;
define VerificationCompleteNum / sum noprint center;
define pct4 / computed format=percent8.1 noprint center;
define comb4 / computed format=$20. 'Verification Complete' center;
define Verifiedbin / sum noprint center;
define pct5 / computed format=percent8.1 noprint center;
define comb5 / computed format=$20. 'Verified' center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1;
pct1=signedin.sum/recruittype.sum;
endcomp;
 
compute comb1 / char;
comb1=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2;
pct2=consented.sum/signedin.sum;
endcomp;
 
compute comb2 / char;
comb2=catt(strip(put(_c6_,8.)),' (',strip(put(_c7_,percent8.1)),')');
endcomp;
 
compute pct3;
pct3=submitted.sum/consented.sum;
endcomp;
 
compute comb3 / char;
comb3=catt(strip(put(_c9_,8.)),' (',strip(put(_c10_,percent8.1)),')');
endcomp;
 
compute pct4;
pct4=VerificationCompleteNum.sum/submitted.sum;
endcomp;
 
compute comb4 / char;
comb4=catt(strip(put(_c12_,8.)),' (',strip(put(_c13_,percent8.1)),')');
endcomp;
 
compute pct5;
pct5=Verifiedbin.sum/VerificationCompleteNum.sum;
endcomp;
 
compute comb5 / char;
comb5=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

ods pdf startpage= no;
*Cumulative Status Active Only Table;
Proc odstext;
p "Cumulative Status for Active Only" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
Title Cumulative Status for Active Only; 
proc report data=concept_ids;
column sitechar
recruittype
SignedIn pct1 comb1 
Consented pct2 comb2 
Submitted pct3 comb3 
VerificationCompleteNum pct4 comb4
Verifiedbin pct5 comb5;
define sitechar / group center;
define recruittype / sum 'Total Active Recruits' style(column)=[cellwidth=0.95in] center;
define signedin / sum noprint center;
define pct1 / computed format=percent8.1 noprint center;
define comb1 / computed format=$20. 'Signed In' center;
define consented / sum noprint center;
define pct2 / computed format=percent8.1 noprint center;
define comb2 / computed format=$20. 'Consented' center;
define submitted / sum noprint center;
define pct3 / computed format=percent8.1 noprint center;
define comb3 / computed format=$20. 'User Profile Submitted' center;
define VerificationCompleteNum / sum noprint center;
define pct4 / computed format=percent8.1 noprint center;
define comb4 / computed format=$20. 'Verification Complete' center;
define Verifiedbin / sum noprint center;
define pct5 / computed format=percent8.1 noprint center;
define comb5 / computed format=$20. 'Verified' center;
WHERE RcrtSI_RecruitType_v1r0 = 486306141;
 
compute pct1;
pct1=signedin.sum/recruittype.sum;
endcomp;
 
compute comb1 / char;
comb1=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2;
pct2=consented.sum/signedin.sum;
endcomp;
 
compute comb2 / char;
comb2=catt(strip(put(_c6_,8.)),' (',strip(put(_c7_,percent8.1)),')');
endcomp;
 
compute pct3;
pct3=submitted.sum/consented.sum;
endcomp;
 
compute comb3 / char;
comb3=catt(strip(put(_c9_,8.)),' (',strip(put(_c10_,percent8.1)),')');
endcomp;
 
compute pct4;
pct4=VerificationCompleteNum.sum/submitted.sum;
endcomp;
 
compute comb4 / char;
comb4=catt(strip(put(_c12_,8.)),' (',strip(put(_c13_,percent8.1)),')');
endcomp;
 
compute pct5;
pct5=Verifiedbin.sum/VerificationCompleteNum.sum;
endcomp;
 
compute comb5 / char;
comb5=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;
 
rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

ods pdf startpage= yes;
*Cumulative Status Passive Only Table;

/*Trying to create method to display all values, even when 0;
data my_format_input;                                                                                                                   
   set work.concept_ids;                                                                                                                          
   start=sitechar;                                                                                                                           
   label=Site;                                                                                                                           
   fmtname='$myfmt';                                                                                                                       
run;  
proc format cntlin=my_format_input;                                                                                                     
run; */

/*Proc odstext;
p "Cumulative Status for Passive Only" /style=[fontweight=bold fontsize=11pt just=c];
;
run;*/
Title Cumulative Status for Passive Only; 
proc report data=concept_ids completerows /*missing*/;
column sitechar
recruittype
SignedIn pct1 comb1 
Consented pct2 comb2 
Submitted pct3 comb3 
VerificationCompleteNum pct4 comb4
Verifiedbin pct5 comb5;
define sitechar / group /*preloadfmt format=$myfmt.*/ center;
define recruittype / sum 'Total Passive Recruits' style(column)=[cellwidth=0.95in] center;
define signedin / sum noprint center;
define pct1 / computed format=percent8.1 noprint center;
define comb1 / computed format=$20. 'Signed In' center;
define consented / sum noprint center;
define pct2 / computed format=percent8.1 noprint center;
define comb2 / computed format=$20. 'Consented' center;
define submitted / sum noprint center;
define pct3 / computed format=percent8.1 noprint center;
define comb3 / computed format=$20. 'User Profile Submitted' center;
define VerificationCompleteNum / sum noprint center;
define pct4 / computed format=percent8.1 noprint center;
define comb4 / computed format=$20. 'Verification Complete' center;
define Verifiedbin / sum noprint center;
define pct5 / computed format=percent8.1 noprint center;
define comb5 / computed format=$20. 'Verified' center;
WHERE RcrtSI_RecruitType_v1r0 = 854703046;
 
compute pct1;
pct1=signedin.sum/recruittype.sum;
endcomp;
 
compute comb1 / char;
comb1=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2;
pct2=consented.sum/signedin.sum;
endcomp;
 
compute comb2 / char;
comb2=catt(strip(put(_c6_,8.)),' (',strip(put(_c7_,percent8.1)),')');
endcomp;
 
compute pct3;
pct3=submitted.sum/consented.sum;
endcomp;
 
compute comb3 / char;
comb3=catt(strip(put(_c9_,8.)),' (',strip(put(_c10_,percent8.1)),')');
endcomp;
 
compute pct4;
pct4=VerificationCompleteNum.sum/submitted.sum;
endcomp;
 
compute comb4 / char;
comb4=catt(strip(put(_c12_,8.)),' (',strip(put(_c13_,percent8.1)),')');
endcomp;
 
compute pct5;
pct5=Verifiedbin.sum/VerificationCompleteNum.sum;
endcomp;
 
compute comb5 / char;
comb5=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;
 
rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

ods pdf startpage=yes;

/*CURRENT STATUS IN WORKFLOW TABLES*/

*Creating total (active + passive) recruits var;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 NE 180583933 THEN TotRcrt = 1;
ELSE TotRcrt = 0;
RUN;

*Creating total active recruits var;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 THEN TotRcrtAct = 1;
ELSE TotRcrtAct = 0;
RUN;

*Creating total passive recruits var;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 854703046 THEN TotRcrtPas = 1;
ELSE TotRcrtPas = 0;
RUN;

*Current Status in Workflow Total Table;
Title Current Status in Workflow Total; 
proc report data=concept_ids;
column sitechar 
TotRcrt SignInReverse pct1_1 comb1_1 TotRcrt
SignInNoConsent pct2_1 comb2_1 TotRcrt
ConsentNoUP pct3_1 comb3_1 TotRcrt
SubmitUPNoVerif pct4_1 comb4_1 TotRcrt
VerificationCompleteNum pct5_1 comb5_1 n;
define sitechar / group center;
define TotRcrt / sum noprint;
define SignInReverse / sum noprint center;
define pct1_1 / computed format=percent8.1 noprint center;
define comb1_1 / computed format=$20. 'Never Signed In' style(column)=[cellwidth=1in] center;
define SignInNoConsent / sum noprint center;
define pct2_1 / computed format=percent8.1 noprint center;
define comb2_1 / computed format=$20. 'Signed In, No Consent' style(column)=[cellwidth=1in] center;
define ConsentNoUP / sum noprint center;
define pct3_1 / computed format=percent8.1 noprint center;
define comb3_1 / computed format=$20. 'Consented, No Profile' style(column)=[cellwidth=1in] center;
define SubmitUPNoVerif / sum noprint center;
define pct4_1 / computed format=percent8.1 noprint center;
define comb4_1 / computed format=$20. 'Profile, Verification Incomplete' style(column)=[cellwidth=1in] center;
define VerificationCompleteNum / sum noprint center;
define pct5_1 / computed format=percent8.1 noprint center;
define comb5_1 / computed format=$20. 'Verification Complete' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_1;
pct1_1=SignInReverse.sum/TotRcrt.sum;
endcomp;
 
compute comb1_1 / char;
comb1_1=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2_1;
pct2_1=SignInNoConsent.sum/TotRcrt.sum;
endcomp;
 
compute comb2_1 / char;
comb2_1=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;
 
compute pct3_1;
pct3_1=ConsentNoUP.sum/TotRcrt.sum;
endcomp;
 
compute comb3_1 / char;
comb3_1=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;
 
compute pct4_1;
pct4_1=SubmitUPNoVerif.sum/TotRcrt.sum;
endcomp;
 
compute comb4_1 / char;
comb4_1=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;
 
compute pct5_1;
pct5_1=VerificationCompleteNum.sum/TotRcrt.sum;
endcomp;
 
compute comb5_1 / char;
comb5_1=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

ods startpage = no;
Proc odstext;
p "Current Status in Workflow for Active Only" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
*Current Status in Workflow Active Table;
Title Current Status in Workflow for Active Only; 
proc report data=concept_ids;
column sitechar 
TotRcrt SignInReverse pct1_1 comb1_1 TotRcrt
SignInNoConsent pct2_1 comb2_1 TotRcrt
ConsentNoUP pct3_1 comb3_1 TotRcrt
SubmitUPNoVerif pct4_1 comb4_1 TotRcrt
VerificationCompleteNum pct5_1 comb5_1 n;
define sitechar / group center;
define TotRcrt / sum noprint;
define SignInReverse / sum noprint center;
define pct1_1 / computed format=percent8.1 noprint center;
define comb1_1 / computed format=$20. 'Never Signed In' style(column)=[cellwidth=1in] center;
define SignInNoConsent / sum noprint center;
define pct2_1 / computed format=percent8.1 noprint center;
define comb2_1 / computed format=$20. 'Signed In, No Consent' style(column)=[cellwidth=1in] center;
define ConsentNoUP / sum noprint center;
define pct3_1 / computed format=percent8.1 noprint center;
define comb3_1 / computed format=$20. 'Consented, No Profile' style(column)=[cellwidth=1in] center;
define SubmitUPNoVerif / sum noprint center;
define pct4_1 / computed format=percent8.1 noprint center;
define comb4_1 / computed format=$20. 'Profile, Verification Incomplete' style(column)=[cellwidth=1in] center;
define VerificationCompleteNum / sum noprint center;
define pct5_1 / computed format=percent8.1 noprint center;
define comb5_1 / computed format=$20. 'Verification Complete' style(column)=[cellwidth=1in] center;
define n / 'Total Active Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 = 486306141;

compute pct1_1;
pct1_1=SignInReverse.sum/TotRcrt.sum;
endcomp;
 
compute comb1_1 / char;
comb1_1=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2_1;
pct2_1=SignInNoConsent.sum/TotRcrt.sum;
endcomp;
 
compute comb2_1 / char;
comb2_1=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;
 
compute pct3_1;
pct3_1=ConsentNoUP.sum/TotRcrt.sum;
endcomp;
 
compute comb3_1 / char;
comb3_1=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;
 
compute pct4_1;
pct4_1=SubmitUPNoVerif.sum/TotRcrt.sum;
endcomp;
 
compute comb4_1 / char;
comb4_1=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;
 
compute pct5_1;
pct5_1=VerificationCompleteNum.sum/TotRcrt.sum;
endcomp;
 
compute comb5_1 / char;
comb5_1=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

ods startpage = yes;

*Current Status in Workflow Passive Table;
Title Current Status in Workflow for Passive Only; 
proc report data=concept_ids;
column sitechar 
TotRcrt SignInReverse pct1_1 comb1_1 TotRcrt
SignInNoConsent pct2_1 comb2_1 TotRcrt
ConsentNoUP pct3_1 comb3_1 TotRcrt
SubmitUPNoVerif pct4_1 comb4_1 TotRcrt
VerificationCompleteNum pct5_1 comb5_1 n;
define sitechar / group center;
define TotRcrt / sum noprint;
define SignInReverse / sum noprint center;
define pct1_1 / computed format=percent8.1 noprint center;
define comb1_1 / computed format=$20. 'Never Signed In' style(column)=[cellwidth=1in] center;
define SignInNoConsent / sum noprint center;
define pct2_1 / computed format=percent8.1 noprint center;
define comb2_1 / computed format=$20. 'Signed In, No Consent' style(column)=[cellwidth=1in] center;
define ConsentNoUP / sum noprint center;
define pct3_1 / computed format=percent8.1 noprint center;
define comb3_1 / computed format=$20. 'Consented, No Profile' style(column)=[cellwidth=1in] center;
define SubmitUPNoVerif / sum noprint center;
define pct4_1 / computed format=percent8.1 noprint center;
define comb4_1 / computed format=$20. 'Profile, Verification Incomplete' style(column)=[cellwidth=1in] center;
define VerificationCompleteNum / sum noprint center;
define pct5_1 / computed format=percent8.1 noprint center;
define comb5_1 / computed format=$20. 'Verification Complete' style(column)=[cellwidth=1in] center;
define n / 'Total Passive Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 = 854703046;

compute pct1_1;
pct1_1=SignInReverse.sum/TotRcrt.sum;
endcomp;
 
compute comb1_1 / char;
comb1_1=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2_1;
pct2_1=SignInNoConsent.sum/TotRcrt.sum;
endcomp;
 
compute comb2_1 / char;
comb2_1=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;
 
compute pct3_1;
pct3_1=ConsentNoUP.sum/TotRcrt.sum;
endcomp;
 
compute comb3_1 / char;
comb3_1=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;
 
compute pct4_1;
pct4_1=SubmitUPNoVerif.sum/TotRcrt.sum;
endcomp;
 
compute comb4_1 / char;
comb4_1=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;
 
compute pct5_1;
pct5_1=VerificationCompleteNum.sum/TotRcrt.sum;
endcomp;
 
compute comb5_1 / char;
comb5_1=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*PRE-CONSENT OPT-OUT TABLES*/
ods pdf startpage= yes;

*Create 0/1 Variables for Opt-Out = Yes and Opt-Out = No;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_OptOut_v1r0 = 353358909 THEN OptOutYes = 1;
ELSE OptOutYes = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_OptOut_v1r0 = 104430631 THEN OptOutNo = 1;
ELSE OptOutNo = 0;
RUN;

*Pre-Consent Opt-Out Among Active Only;
Title Pre-Consent Opt-Out Among Active Only; 
proc report data=concept_ids;
column sitechar 
TotRcrt OptOutYes pct1_2 comb1_2 TotRcrt
OptOutNo pct2_2 comb2_2 n;
define sitechar / group center;
define TotRcrt / sum noprint;
define OptOutYes / sum noprint center;
define pct1_2 / computed format=percent8.1 noprint center;
define comb1_2 / computed format=$20. 'Yes' style(column)=[cellwidth=1in] center;
define OptOutNo / sum noprint center;
define pct2_2 / computed format=percent8.1 noprint center;
define comb2_2 / computed format=$20. 'No' style(column)=[cellwidth=1.4in] center;
define n / 'Total Active Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 = 486306141;

compute pct1_2;
pct1_2=OptOutYes.sum/TotRcrt.sum;
endcomp;
 
compute comb1_2 / char;
comb1_2=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2_2;
pct2_2=OptOutNo.sum/TotRcrt.sum;
endcomp;
 
compute comb2_2 / char;
comb2_2=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Timing of Pre-consent Opt Out Among Active Recruits;
ods pdf startpage= no;
*Creating Vars for Opt-Out and Never Signed in, and Opt-Out and Signed in No Consent;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_OptOut_v1r0 = 353358909 AND RcrtSI_SignedIn_v1r0 = 104430631 THEN OptOutNoSignInBin = 1;
ELSE OptOutNoSignInBin = 0; 

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_OptOut_v1r0 = 353358909 AND RcrtSI_SignedIn_v1r0 = 353358909 AND RcrtCS_Consented_v1r0 = 104430631
THEN OptOutNoConsentBin = 1;
ELSE OptOutNoConsentBin = 0;
RUN;

Proc odstext;
p "Timing of Pre-consent Opt Out Among Active Recruits" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
Title Timing of Pre-consent Opt Out Among Active Recruits; 
proc report data=concept_ids;
column sitechar 
TotRcrt OptOutNoSignInBin pct1_3 comb1_3 TotRcrt
OptOutNoConsentBin pct2_3 comb2_3 n;
define sitechar / group center;
define TotRcrt / sum noprint;
define OptOutNoSignInBin / sum noprint center;
define pct1_3 / computed format=percent8.1 noprint center;
define comb1_3 / computed format=$20. 'Never Signed In' style(column)=[cellwidth=1in] center;
define OptOutNoConsentBin / sum noprint center;
define pct2_3 / computed format=percent8.1 noprint center;
define comb2_3 / computed format=$20. 'Signed In, No Consent' style(column)=[cellwidth=1in] center;
define n / 'Total Active Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 = 486306141;

compute pct1_3;
pct1_3=OptOutNoSignInBin.sum/TotRcrt.sum;
endcomp;
 
compute comb1_3 / char;
comb1_3=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2_3;
pct2_3=OptOutNoConsentBin.sum/TotRcrt.sum;
endcomp;
 
compute comb2_3 / char;
comb2_3=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*VERIFICATION STATUS AMONG THOSE THAT HAVE SUBMITTED USER PROFILE*/
*Creating 0/1 variables for verification status;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 875007964 THEN NotVerifiedBinTable = 1;
ELSE NotVerifiedBinTable = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 THEN VerifiedBinTable = 1;
ELSE VerifiedBinTable = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 THEN CBVBinTable = 1;
ELSE CBVBinTable = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 922622075 THEN DuplicateBinTable = 1;
ELSE DuplicateBinTable = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 160161595 THEN OutreachBinTable = 1;
ELSE OutreachBinTable = 0;
RUN;

ods pdf startpage=yes;
Title Verification Status Among Those That Have Submitted User Profile;
proc report data=concept_ids;
column sitechar 
TotRcrt NotVerifiedBinTable pct1_3_5 comb1_3_5 TotRcrt
VerifiedBinTable pct2_3_5 comb2_3_5 TotRcrt
CBVBinTable pct3_3_5 comb3_3_5 TotRcrt
DuplicateBinTable pct4_3_5 comb4_3_5 TotRcrt
OutreachBinTable pct5_3_5 comb5_3_5 n;
define sitechar / group center;
define TotRcrt / sum noprint;
define NotVerifiedBinTable / sum noprint center;
define pct1_3_5 / computed format=percent8.1 noprint center;
define comb1_3_5 / computed format=$20. 'Not Yet Verified' style(column)=[cellwidth=1in] center;
define VerifiedBinTable / sum noprint center;
define pct2_3_5 / computed format=percent8.1 noprint center;
define comb2_3_5 / computed format=$20. 'Verified' style(column)=[cellwidth=1in] center;
define CBVBinTable/ sum noprint center;
define pct3_3_5 / computed format=percent8.1 noprint center;
define comb3_3_5 / computed format=$20. 'Cannot Be Verified' style(column)=[cellwidth=1in] center;
define DuplicateBinTable / sum noprint center;
define pct4_3_5 / computed format=percent8.1 noprint center;
define comb4_3_5 / computed format=$20. 'Duplicate' style(column)=[cellwidth=1in] center;
define OutreachBinTable / sum noprint center;
define pct5_3_5 / computed format=percent8.1 noprint center;
define comb5_3_5 / computed format=$20. 'Outreach Timed Out' style(column)=[cellwidth=1in] center;
define TotRcrt /sum noprint;
define n / 'Total Submitted User Profile' style(column)=[cellwidth=1in] center;
WHERE RcrtUP_Submitted_v1r0 = 353358909;

compute pct1_3_5;
pct1_3_5=NotVerifiedBinTable.sum/TotRcrt.sum;
endcomp;
 
compute comb1_3_5 / char;
comb1_3_5=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;
 
compute pct2_3_5;
pct2_3_5=VerifiedBinTable.sum/TotRcrt.sum;
endcomp;
 
compute comb2_3_5 / char;
comb2_3_5=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_3_5;
pct3_3_5=CBVBinTable.sum/TotRcrt.sum;
endcomp;
 
compute comb3_3_5 / char;
comb3_3_5=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_3_5;
pct4_3_5=DuplicateBinTable.sum/TotRcrt.sum;
endcomp;
 
compute comb4_3_5 / char;
comb4_3_5=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_3_5;
pct5_3_5=OutreachBinTable.sum/TotRcrt.sum;
endcomp;
 
compute comb5_3_5 / char;
comb5_3_5=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*DE-IDENTIFIED DEMOGRAPHICS OF VERIFIED PARTICIPANTS TABLES*/
ods pdf startpage=yes;

*Age of Verified Participants;
*Creating Verified Only Dataset for denominator;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 THEN VerifiedRcrt = 1;
ELSE VerifiedRcrt = 0;
RUN; 

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF VerifiedRcrt = 1 THEN VerifiedRcrt2 = 1;
ELSE VerifiedRcrt2 = 0;
RUN;

*Creating individual age range vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF AgeVerified = 1 THEN Age4045 = 1;
ELSE Age4045 = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF AgeVerified = 2 THEN Age4650 = 1;
ELSE Age4650 = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF AgeVerified = 3 THEN Age5155 = 1;
ELSE Age5155 = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF AgeVerified = 4 THEN Age5660 = 1;
ELSE Age5660 = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF AgeVerified = 5 THEN Age6165 = 1;
ELSE Age6165 = 0;
RUN;

Title Age of Verified Participants; 
proc report data=concept_ids;
column sitechar 
VerifiedRcrt Age4045 pct1_4 comb1_4 VerifiedRcrt
Age4650 pct2_4 comb2_4 VerifiedRcrt
Age5155 pct3_4 comb3_4 VerifiedRcrt
Age5660 pct4_4 comb4_4 VerifiedRcrt
Age6165 pct5_4 comb5_4 VerifiedRcrt2;
define sitechar / group center;
define Age4045 /sum center noprint;
define pct1_4 / computed format=percent8.1 noprint center;
define comb1_4 / computed format=$20. '40-45' style(column)=[cellwidth=1in] center;
define Age4650 /sum center noprint;
define pct2_4 / computed format=percent8.1 noprint center;
define comb2_4 / computed format=$20. '46-50' style(column)=[cellwidth=1in] center;
define Age5155 /sum noprint center;
define pct3_4 / computed format=percent8.1 noprint center;
define comb3_4 / computed format=$20. '51-55' style(column)=[cellwidth=1in] center;
define Age5660 /sum noprint center;
define pct4_4 / computed format=percent8.1 noprint center;
define comb4_4 / computed format=$20. '56-60' style(column)=[cellwidth=1in] center;
define Age6165 /sum noprint center;
define pct5_4 / computed format=percent8.1 noprint center;
define comb5_4 / computed format=$20. '61-65' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_4;
pct1_4=Age4045.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_4 / char;
comb1_4=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_4;
pct2_4=Age4650.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_4 / char;
comb2_4=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_4;
pct3_4=Age5155.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_4 / char;
comb3_4=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_4;
pct4_4=Age5660.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb4_4 / char;
comb4_4=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_4;
pct5_4=Age6165.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb5_4 / char;
comb5_4=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Race of Verified Participants;
ods pdf startpage= no;

*Creating individual race vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RaceVerified = 1 THEN RaceWhite = 1;
ELSE RaceWhite = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RaceVerified = 2 THEN RaceOther = 1;
ELSE RaceOther = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RaceVerified = 3 THEN RaceUnknown = 1;
ELSE RaceUnknown = 0;
RUN;

Proc odstext;
p "Race of Verified Participants" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
Title Race of Verified Participants; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
VerifiedRcrt RaceWhite pct1_5 comb1_5 VerifiedRcrt
RaceOther pct2_5 comb2_5 VerifiedRcrt
RaceUnknown pct3_5 comb3_5 VerifiedRcrt2;
define sitechar / group center;
define RaceWhite /sum center noprint;
define pct1_5 / computed format=percent8.1 noprint center;
define comb1_5 / computed format=$20. 'White, Non-Hispanic' style(column)=[cellwidth=1in] center;
define RaceOther /sum center noprint;
define pct2_5 / computed format=percent8.1 noprint center;
define comb2_5 / computed format=$20. 'Other' style(column)=[cellwidth=1in] center;
define RaceUnknown /sum noprint center;
define pct3_5 / computed format=percent8.1 noprint center;
define comb3_5 / computed format=$20. 'Unavailable/Unknown' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933 AND RcrtV_Verification_v1r0 = 197316935;

compute pct1_5;
pct1_5=RaceWhite.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_5 / char;
comb1_5=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_5;
pct2_5=RaceOther.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_5 / char;
comb2_5=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_5;
pct3_5=RaceUnknown.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_5 / char;
comb3_5=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Sex of Verified Participants;
ods pdf startpage=yes;

*Creating individual sex vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SexVerified = 1 THEN FemaleBin = 1;
ELSE FemaleBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SexVerified = 2 THEN MaleBin = 1;
ELSE MaleBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SexVerified = 3 THEN IntersexBin = 1;
ELSE IntersexBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SexVerified = 4 THEN UnknownBin = 1;
ELSE UnknownBin = 0;
RUN;

Title Sex of Verified Participants; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
VerifiedRcrt FemaleBin pct1_6 comb1_6 VerifiedRcrt
MaleBin pct2_6 comb2_6 VerifiedRcrt
IntersexBin pct3_6 comb3_6 VerifiedRcrt
UnknownBin pct4_6 comb4_6 VerifiedRcrt2;
define sitechar / group center;
define FemaleBin /sum center noprint;
define pct1_6 / computed format=percent8.1 noprint center;
define comb1_6 / computed format=$20. 'Female' style(column)=[cellwidth=1in] center;
define MaleBin /sum center noprint;
define pct2_6 / computed format=percent8.1 noprint center;
define comb2_6 / computed format=$20. 'Male' style(column)=[cellwidth=1in] center;
define IntersexBin /sum noprint center;
define pct3_6 / computed format=percent8.1 noprint center;
define comb3_6 / computed format=$20. 'Intersex or Other' style(column)=[cellwidth=1in] center;
define UnknownBin /sum noprint center;
define pct4_6 / computed format=percent8.1 noprint center;
define comb4_6 / computed format=$20. 'Unavailable/Unknown' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_6;
pct1_6=FemaleBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_6 / char;
comb1_6=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_6;
pct2_6=MaleBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_6 / char;
comb2_6=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_6;
pct3_6=IntersexBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_6 / char;
comb3_6=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_6;
pct4_6=UnknownBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb4_6 / char;
comb4_6=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*COMPLETION OF ACTIVITIES FOR VERIFIED PARTICIPANTS*/
*Completion of Initial Survey; 
ods pdf startpage=yes;

*Creating individual completion of Initial Survey vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF ComplIntlSrvVer = "None" THEN NoneBin = 1;
ELSE NoneBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF ComplIntlSrvVer = "BOH Only" THEN BOHBin = 1;
ELSE BOHBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF ComplIntlSrvVer = "2 or 3 sections" THEN TwoOrThreeBin = 1;
ELSE TwoOrThreeBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF ComplIntlSrvVer = "All" THEN AllSrvBin = 1;
ELSE AllSrvBin = 0;
RUN;

Title Completion of Initial Survey for Verified Participants; 
proc report data=concept_ids;
column sitechar 
VerifiedRcrt NoneBin pct1_7 comb1_7 VerifiedRcrt
BOHBin pct2_7 comb2_7 VerifiedRcrt
TwoOrThreeBin pct3_7 comb3_7 VerifiedRcrt
AllSrvBin pct4_7 comb4_7 VerifiedRcrt2;
define sitechar / group center;
define NoneBin /sum center noprint;
define pct1_7 / computed format=percent8.1 noprint center;
define comb1_7 / computed format=$20. 'None' style(column)=[cellwidth=1in] center;
define BOHBin /sum center noprint;
define pct2_7 / computed format=percent8.1 noprint center;
define comb2_7 / computed format=$20. 'BOH Only' style(column)=[cellwidth=1in] center;
define TwoOrThreeBin /sum noprint center;
define pct3_7 / computed format=percent8.1 noprint center;
define comb3_7 / computed format=$20. '2 or 3 Sections' style(column)=[cellwidth=1in] center;
define AllSrvBin /sum noprint center;
define pct4_7 / computed format=percent8.1 noprint center;
define comb4_7 / computed format=$20. 'All' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_7;
pct1_7=NoneBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_7 / char;
comb1_7=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_7;
pct2_7=BOHBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_7 / char;
comb2_7=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_7;
pct3_7=TwoOrThreeBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_7 / char;
comb3_7=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_7;
pct4_7=AllSrvBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb4_7 / char;
comb4_7=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*SSN Status for Verified Participants;
ods pdf startpage= no;

*Creating individual completion of SSN Status vars;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SSNPieVerified = "No SSN Given" THEN NoSSNBin = 1;
ELSE NoSSNBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SSNPieVerified = "Partial SSN Given" THEN PartialSSNBin = 1;
ELSE PartialSSNBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SSNPieVerified = "Full SSN Given" THEN FullSSNBin = 1;
ELSE FullSSNBin = 0;
RUN;

Proc odstext;
p "SSN Status for Verified Participants" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
Title SSN Status for Verified Participants; 
proc report data=concept_ids;
column sitechar 
VerifiedRcrt NoSSNBin pct1_8 comb1_8 VerifiedRcrt
PartialSSNBin pct2_8 comb2_8 VerifiedRcrt
FullSSNBin pct3_8 comb3_8 VerifiedRcrt2;
define sitechar / group center;
define NoSSNBin /sum center noprint;
define pct1_8 / computed format=percent8.1 noprint center;
define comb1_8 / computed format=$20. 'No SSN Given' style(column)=[cellwidth=1in] center;
define PartialSSNBin /sum center noprint;
define pct2_8 / computed format=percent8.1 noprint center;
define comb2_8 / computed format=$20. 'Partial SSN Given' style(column)=[cellwidth=1in] center;
define FullSSNBin /sum noprint center;
define pct3_8 / computed format=percent8.1 noprint center;
define comb3_8 / computed format=$20. 'Full SSN Given' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_8;
pct1_8=NoSSNBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_8 / char;
comb1_8=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_8;
pct2_8=PartialSSNBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_8 / char;
comb2_8=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_8;
pct3_8=FullSSNBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_8 / char;
comb3_8=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*DE-IDENTIFIED DEMOGRAPHICS AMONG ALL RECORDS*/
ods pdf startpage=yes;

*Age Among All Records;
*Creating individual age range vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Age_v1r0 = 124276120 THEN Age4045All = 1;
ELSE Age4045All = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Age_v1r0 = 450985724 THEN Age4650All = 1;
ELSE Age4650All = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Age_v1r0 = 363147933 THEN Age5155All = 1;
ELSE Age5155All = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Age_v1r0 = 636706443 THEN Age5660All = 1;
ELSE Age5660All = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Age_v1r0 = 771230670 THEN Age6165All = 1;
ELSE Age6165All = 0;
RUN;

Title Age Among All Records; 
proc report data=concept_ids;
column sitechar 
TotRcrt Age4045All pct1_9 comb1_9 TotRcrt
Age4650All pct2_9 comb2_9 TotRcrt
Age5155All pct3_9 comb3_9 TotRcrt
Age5660All pct4_9 comb4_9 TotRcrt
Age6165All pct5_9 comb5_9 n;
define sitechar / group center;
define Age4045All /sum center noprint;
define pct1_9 / computed format=percent8.1 noprint center;
define comb1_9 / computed format=$20. '40-45' style(column)=[cellwidth=1in] center;
define Age4650All /sum center noprint;
define pct2_9 / computed format=percent8.1 noprint center;
define comb2_9 / computed format=$20. '46-50' style(column)=[cellwidth=1in] center;
define Age5155All /sum noprint center;
define pct3_9 / computed format=percent8.1 noprint center;
define comb3_9 / computed format=$20. '51-55' style(column)=[cellwidth=1in] center;
define Age5660All /sum noprint center;
define pct4_9 / computed format=percent8.1 noprint center;
define comb4_9 / computed format=$20. '56-60' style(column)=[cellwidth=1in] center;
define Age6165All /sum noprint center;
define pct5_9 / computed format=percent8.1 noprint center;
define comb5_9 / computed format=$20. '61-65' style(column)=[cellwidth=1in] center;
define TotRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_9;
pct1_9=Age4045All.sum/TotRcrt.sum;
endcomp;
 
compute comb1_9 / char;
comb1_9=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_9;
pct2_9=Age4650All.sum/TotRcrt.sum;
endcomp;
 
compute comb2_9 / char;
comb2_9=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_9;
pct3_9=Age5155All.sum/TotRcrt.sum;
endcomp;
 
compute comb3_9 / char;
comb3_9=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_9;
pct4_9=Age5660All.sum/TotRcrt.sum;
endcomp;
 
compute comb4_9 / char;
comb4_9=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_9;
pct5_9=Age6165All.sum/TotRcrt.sum;
endcomp;
 
compute comb5_9 / char;
comb5_9=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Race Among All Records;
ods pdf startpage= no;

*Creating individual race vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Race_v1r0 = 768826601 THEN RaceWhiteAll = 1;
ELSE RaceWhiteAll = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Race_v1r0 = 181769837 THEN RaceOtherAll = 1;
ELSE RaceOtherAll = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Race_v1r0 = 178420302 THEN RaceUnknownAll = 1;
ELSE RaceUnknownAll = 0;
RUN;

Proc odstext;
p "Race Among All Records" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
Title Race Among All Records; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
TotRcrt RaceWhiteAll pct1_10 comb1_10 TotRcrt
RaceOtherAll pct2_10 comb2_10 TotRcrt
RaceUnknownAll pct3_10 comb3_10 n;
define sitechar / group center;
define RaceWhiteAll /sum center noprint;
define pct1_10 / computed format=percent8.1 noprint center;
define comb1_10 / computed format=$20. 'White, Non-Hispanic' style(column)=[cellwidth=1in] center;
define RaceOtherAll /sum center noprint;
define pct2_10 / computed format=percent8.1 noprint center;
define comb2_10 / computed format=$20. 'Other' style(column)=[cellwidth=1in] center;
define RaceUnknownAll /sum noprint center;
define pct3_10 / computed format=percent8.1 noprint center;
define comb3_10 / computed format=$20. 'Unavailable/Unknown' style(column)=[cellwidth=1in] center;
define TotRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_10;
pct1_10=RaceWhiteAll.sum/TotRcrt.sum;
endcomp;
 
compute comb1_10 / char;
comb1_10=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_10;
pct2_10=RaceOtherAll.sum/TotRcrt.sum;
endcomp;
 
compute comb2_10 / char;
comb2_10=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_10;
pct3_10=RaceUnknownAll.sum/TotRcrt.sum;
endcomp;
 
compute comb3_10 / char;
comb3_10=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Sex Among All Records;
ods pdf startpage=yes;

*Creating individual sex vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Sex_v1r0 = 536341288 THEN FemaleBinAll = 1;
ELSE FemaleBinAll = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Sex_v1r0 = 654207589 THEN MaleBinAll = 1;
ELSE MaleBinAll = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Sex_v1r0 = 830573274 THEN IntersexBinAll = 1;
ELSE IntersexBinAll = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_Sex_v1r0 = 178420302 THEN UnknownBinAll = 1;
ELSE UnknownBinAll = 0;
RUN;

Title Sex Among All Records; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
TotRcrt FemaleBinAll pct1_11 comb1_11 TotRcrt
MaleBinAll pct2_11 comb2_11 TotRcrt
IntersexBinAll pct3_11 comb3_11 TotRcrt
UnknownBinAll pct4_11 comb4_11 n;
define sitechar / group center;
define FemaleBinAll /sum center noprint;
define pct1_11 / computed format=percent8.1 noprint center;
define comb1_11 / computed format=$20. 'Female' style(column)=[cellwidth=1in] center;
define MaleBinAll /sum center noprint;
define pct2_11 / computed format=percent8.1 noprint center;
define comb2_11 / computed format=$20. 'Male' style(column)=[cellwidth=1in] center;
define IntersexBinAll /sum noprint center;
define pct3_11 / computed format=percent8.1 noprint center;
define comb3_11 / computed format=$20. 'Intersex or Other' style(column)=[cellwidth=1in] center;
define UnknownBinAll /sum noprint center;
define pct4_11 / computed format=percent8.1 noprint center;
define comb4_11 / computed format=$20. 'Unavailable/Unknown' style(column)=[cellwidth=1in] center;
define TotRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_11;
pct1_11=FemaleBinAll.sum/TotRcrt.sum;
endcomp;
 
compute comb1_11 / char;
comb1_11=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_11;
pct2_11=MaleBinAll.sum/TotRcrt.sum;
endcomp;
 
compute comb2_11 / char;
comb2_11=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_11;
pct3_11=IntersexBinAll.sum/TotRcrt.sum;
endcomp;
 
compute comb3_11 / char;
comb3_11=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_11;
pct4_11=UnknownBinAll.sum/TotRcrt.sum;
endcomp;
 
compute comb4_11 / char;
comb4_11=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*ALL RECORDS IN CONNECT BY SITE*/
ods pdf startpage=yes;
Title All Records in Connect By Site; 
proc report data=concept_ids;
column sitechar 
TotRcrt TotRcrtAct pct1_13 comb1_13 TotRcrt
TotRcrtPas pct2_13 comb2_13 n;
define sitechar / group center;
define TotRcrtAct /sum center noprint;
define pct1_13 / computed format=percent8.1 noprint center;
define comb1_13 / computed format=$20. 'Active' style(column)=[cellwidth=1in] center;
define TotRcrtPas /sum center noprint;
define pct2_13 / computed format=percent8.1 noprint center;
define comb2_13 / computed format=$20. 'Passive' style(column)=[cellwidth=1in] center;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_13;
pct1_13=TotRcrtAct.sum/TotRcrt.sum;
endcomp;
 
compute comb1_13 / char;
comb1_13=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_13;
pct2_13=TotRcrtPas.sum/TotRcrt.sum;
endcomp;
 
compute comb2_13 / char;
comb2_13=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*VERIFIED PARTICIPANTS AND RESPONSE RATIO*/
ods pdf startpage=no;

*Creating Verified Active and Verified Passive vars;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtV_Verification_v1r0 = 197316935 THEN ActiveVerBin = 1;
ELSE ActiveVerBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 854703046 AND RcrtV_Verification_v1r0 = 197316935 THEN PassiveVerBin = 1;
ELSE PassiveVerBin = 0;
RUN;

Title Verified Participants and Response Ratio; 
Proc odstext;
p "Verified Participants and Response Ratio" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
proc report data=concept_ids;
column sitechar 
TotRcrt ActiveVerBin pct1_14 comb1_14 TotRcrt
PassiveVerBin pct2_14 comb2_14 n;
define sitechar / group center;
define ActiveVerBin /sum center noprint;
define pct1_14 / computed format=percent8.1 noprint center;
define comb1_14 / computed format=$20. 'Active' style(column)=[cellwidth=1in] center;
define PassiveVerBin /sum center noprint;
define pct2_14 / computed format=percent8.1 noprint center;
define comb2_14 / computed format=$20. 'Passive' style(column)=[cellwidth=1in] center;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_14;
pct1_14=ActiveVerBin.sum/TotRcrt.sum;
endcomp;
 
compute comb1_14 / char;
comb1_14=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_14;
pct2_14=PassiveVerBin.sum/TotRcrt.sum;
endcomp;
 
compute comb2_14 / char;
comb2_14=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*COMPLETED BASELINE SURVEY & SAMPLES AMONG VERIFIED PARTICIPANTS AND COMPLETION RATIO*/
ods pdf startpage=yes;

*Creating var for completed baseline activities and verified;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SrvBOH_BaseStatus_v1r0 = 231311385 AND SrvMRE_BaseStatus_v1r0 = 231311385 AND SrvSAS_BaseStatus_v1r0 = 231311385 
AND SrvLAW_BaseStatus_v1r0 = 231311385 AND BioFin_BaseBloodCol_v1r0 = 353358909 AND BioFin_BaseUrineCol_v1r0 = 353358909
AND BioFin_BaseMouthCol_v1r0 = 353358909 AND RcrtV_Verification_v1r0 = 197316935 THEN ComplAllBin = 1;
ELSE ComplAllBin = 0;
RUN;

*Creating var opposite of the one above;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SrvBOH_BaseStatus_v1r0 NE 231311385 OR SrvMRE_BaseStatus_v1r0 NE 231311385 OR SrvSAS_BaseStatus_v1r0 NE 231311385 
OR SrvLAW_BaseStatus_v1r0 NE 231311385 OR BioFin_BaseBloodCol_v1r0 NE 353358909 OR BioFin_BaseUrineCol_v1r0 NE 353358909
OR BioFin_BaseMouthCol_v1r0 NE 353358909 THEN ComplAllBinReverse = 1;
ELSE ComplAllBinReverse = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF ComplAllBinReverse = 1 AND RcrtV_Verification_v1r0 = 197316935 THEN ComplAllBinReverse2 = 1;
ELSE ComplAllBinReverse2 = 0;
RUN;

Title Completed Baseline Survey and Samples among Verified Participants and Completion Ratio; 
proc report data=concept_ids;
column sitechar  
VerifiedRcrt ComplAllBin pct1_15 comb1_15 VerifiedRcrt
ComplAllBinReverse2 pct2_15 comb2_15 VerifiedRcrt2;
define sitechar / group center;
define ComplAllBin /sum center noprint;
define pct1_15 / computed format=percent8.1 noprint center;
define comb1_15 / computed format=$20. 'Yes' style(column)=[cellwidth=1in] center;
define ComplAllBinReverse2 /sum center noprint;
define pct2_15 / computed format=percent8.1 noprint center;
define comb2_15 / computed format=$20. 'No' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_15;
pct1_15=ComplAllBin.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_15 / char;
comb1_15=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_15;
pct2_15= ComplAllBinReverse2.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_15 / char;
comb2_15=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*BASELINE BIOSPECIMENS COLLECTED AMONG VERIFIED PARTICIPANTS*/
ods pdf startpage=yes;

*Creating new vars for biospecimen collections;
*All;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseBloodCol_v1r0 = 353358909 AND BioFin_BaseMouthCol_v1r0 = 353358909 AND 
BioFin_BaseUrineCol_v1r0 = 353358909 AND RcrtV_Verification_v1r0 = 197316935 THEN AllBiosCol = 1;
ELSE AllBiosCol = 0;
RUN;

*None;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseBloodCol_v1r0 = 104430631 AND BioFin_BaseMouthCol_v1r0 = 104430631 AND 
BioFin_BaseUrineCol_v1r0 = 104430631 AND RcrtV_Verification_v1r0 = 197316935 THEN NoneBiosCol = 1;
ELSE NoneBiosCol = 0;
RUN;

*Blood/Urine Only;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseBloodCol_v1r0 = 353358909 AND BioFin_BaseMouthCol_v1r0 = 104430631 AND 
BioFin_BaseUrineCol_v1r0 = 353358909 AND RcrtV_Verification_v1r0 = 197316935 THEN BloodUrineOnlyCol = 1;
ELSE BloodUrineOnlyCol = 0;
RUN;

*Blood/Mouthwash only;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseBloodCol_v1r0 = 353358909 AND BioFin_BaseMouthCol_v1r0 = 353358909 AND 
BioFin_BaseUrineCol_v1r0 = 104430631 AND RcrtV_Verification_v1r0 = 197316935 THEN BloodMWOnlyCol = 1;
ELSE BloodMWOnlyCol = 0;
RUN;

*Urine/Mouthwash only;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseBloodCol_v1r0 = 104430631 AND BioFin_BaseMouthCol_v1r0 = 353358909 AND 
BioFin_BaseUrineCol_v1r0 = 353358909 AND RcrtV_Verification_v1r0 = 197316935 THEN UrineMWOnlyCol = 1;
ELSE UrineMWOnlyCol = 0;
RUN;

*Mouthwash only;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseMouthCol_v1r0 = 353358909 AND BioFin_BaseBloodCol_v1r0 NE 353358909 AND 
BioFin_BaseUrineCol_v1r0 NE 353358909 AND RcrtV_Verification_v1r0 = 197316935 THEN MWOnlyCol = 1;
ELSE MWOnlyCol = 0;
RUN;

*Urine only;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseUrineCol_v1r0 = 353358909 AND BioFin_BaseBloodCol_v1r0 NE 353358909 AND 
BioFin_BaseMouthCol_v1r0 NE 353358909 AND RcrtV_Verification_v1r0 = 197316935 THEN UrineOnlyCol = 1;
ELSE UrineOnlyCol = 0;
RUN;

*Blood only;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF BioFin_BaseBloodCol_v1r0 = 353358909 AND BioFin_BaseMouthCol_v1r0 NE 353358909 AND 
BioFin_BaseUrineCol_v1r0 NE 353358909 AND RcrtV_Verification_v1r0 = 197316935 THEN BloodOnlyCol = 1;
ELSE BloodOnlyCol = 0;
RUN;

Title Baseline Biospecimens Collected Among Verified Participants; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
VerifiedRcrt AllBiosCol pct1_16 comb1_16 VerifiedRcrt
NoneBiosCol pct2_16 comb2_16 VerifiedRcrt
BloodUrineOnlyCol pct3_16 comb3_16 VerifiedRcrt
BloodMWOnlyCol pct4_16 comb4_16 VerifiedRcrt
UrineMWOnlyCol pct5_16 comb5_16 VerifiedRcrt
MWOnlyCol pct6_16 comb6_16 VerifiedRcrt
UrineOnlyCol pct7_16 comb7_16 VerifiedRcrt 
BloodOnlyCol pct8_16 comb8_16 VerifiedRcrt2;
define sitechar / group center;
define AllBiosCol /sum center noprint;
define pct1_16 / computed format=percent8.1 noprint center;
define comb1_16 / computed format=$20. 'All' style(column)=[cellwidth=1in] center;
define NoneBiosCol /sum center noprint;
define pct2_16 / computed format=percent8.1 noprint center;
define comb2_16 / computed format=$20. 'None' style(column)=[cellwidth=1in] center;
define BloodUrineOnlyCol /sum noprint center;
define pct3_16 / computed format=percent8.1 noprint center;
define comb3_16 / computed format=$20. 'Blood/Urine Only' style(column)=[cellwidth=1in] center;
define BloodMWOnlyCol /sum noprint center;
define pct4_16 / computed format=percent8.1 noprint center;
define comb4_16 / computed format=$20. 'Blood/Mouthwash Only' style(column)=[cellwidth=1in] center;
define UrineMWOnlyCol /sum noprint center;
define pct5_16 / computed format=percent8.1 noprint center;
define comb5_16 / computed format=$20. 'Urine/Mouthwash Only' style(column)=[cellwidth=1in] center;
define MWOnlyCol /sum noprint center;
define pct6_16 / computed format=percent8.1 noprint center;
define comb6_16 / computed format=$20. 'Mouthwash Only' style(column)=[cellwidth=1in] center;
define UrineOnlyCol /sum noprint center;
define pct7_16 / computed format=percent8.1 noprint center;
define comb7_16 / computed format=$20. 'Urine Only' style(column)=[cellwidth=1in] center;
define BloodOnlyCol /sum noprint center;
define pct8_16 / computed format=percent8.1 noprint center;
define comb8_16 / computed format=$20. 'Blood Only' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
/*WHERE RcrtSI_RecruitType_v1r0 NE 180583933;*/

compute pct1_16;
pct1_16=AllBiosCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_16 / char;
comb1_16=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_16;
pct2_16=NoneBiosCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_16 / char;
comb2_16=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_16;
pct3_16=BloodUrineOnlyCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_16 / char;
comb3_16=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_16;
pct4_16=BloodMWOnlyCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb4_16 / char;
comb4_16=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_16;
pct5_16=UrineMWOnlyCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb5_16 / char;
comb5_16=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_16;
pct6_16=MWOnlyCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb6_16 / char;
comb6_16=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_16;
pct7_16=UrineOnlyCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb7_16 / char;
comb7_16=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_16;
pct8_16=BloodOnlyCol.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb8_16 / char;
comb8_16=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;
