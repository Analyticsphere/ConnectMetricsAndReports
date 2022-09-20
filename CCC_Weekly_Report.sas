/*****************/
/* Program: CCC_Weekly_Report
/* Program location: C:\Users\natarajanm2\OneDrive - National Institutes of Health\desktop\BQ Testing
/* Updated: 9/20/22
/* SAS Enterprise Guide Version 7.15
/* Author: Madhuri Natarajan
/* Study Name: Connect for Cancer Prevention Study
/*
/* 
/*
/* Description: This is the SAS code for the CCC Weekly Report. 
Run this after the data processing code and CCC Daily Metrics code. 
/*****************/

options PRINTERPATH=PDF;
ods pdf file='C:\Users\natarajanm2\Desktop\CCC_Weekly_Report_Tables.pdf' NOGTITLE
NOGFOOTNOTE startpage=never style=mygradient;
Options nodate nonumber;
/*options bottommargin=0.25in topmargin=0.25in;*/
*Adding Page Numbers to Bottom Right of Page;
ods escapechar="^";
footnote j=right "^{thispage}";
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

*Recruitment Type & Title for Report;
data _null_;
today =
trim(left(put(date(),worddate18.)));
call symput('dtnull',today);
run;

PROC PRINT noobs DATA=recruittypetotal label;
VAR RcrtSI_RecruitType_v1r0 COUNT;
*Title 'All Records in Connect- 5/5/2022';
Title1 height=20pt "CCC Weekly Report – &dtnull";
Title2 " ";
Title3 " ";
Title4 " ";
Title5 " ";
Title6 " ";
Title7 "All Records in Connect";
RUN;

ods pdf startpage= yes;
/*Total Number Verified*/

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

Title Total Number Verified; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
VerifiedRcrt pct1_17 comb1_17 VerifiedRcrt2;
define sitechar / group center;
define VerifiedRcrt /sum center noprint;
define pct1_17 / computed format=percent8.1 noprint center;
define comb1_17 / noprint computed format=$20. 'Verified' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_17;
pct1_17=VerifiedRcrt.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_17 / char;
comb1_17=catt(strip(put(_c2_,8.)),' (',strip(put(_c3_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*VERIFICATION MODE OF THOSE SUCCESSFULLY VERIFIED*/
ods pdf startpage=no;

Title Verification Mode of Those Successfully Verified; 
Proc odstext;
p "Verification Mode of Those Successfully Verified" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
proc report data=concept_ids SPLIT='00'x;
column sitechar 
VerifiedRcrt Automated pct1_18 comb1_18 VerifiedRcrt
Manual pct2_18 comb2_18 VerifiedRcrt
ManualOutreach pct3_18 comb3_18 VerifiedRcrt2;
define sitechar / group center;
define Automated /sum center noprint;
define pct1_18 / computed format=percent8.1 noprint center;
define comb1_18 / computed format=$20. 'Automated Verification' style(column)=[cellwidth=1in] center;
define Manual /sum center noprint;
define pct2_18 / computed format=percent8.1 noprint center;
define comb2_18 / computed format=$20. 'Manual Verification' style(column)=[cellwidth=1in] center;
define ManualOutreach /sum noprint center;
define pct3_18 / computed format=percent8.1 noprint center;
define comb3_18 / computed format=$20. 'Manual Verification and Outreach' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_18;
pct1_18=Automated.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_18 / char;
comb1_18=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_18;
pct2_18=Manual.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_18 / char;
comb2_18=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_18;
pct3_18=ManualOutreach.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_18 / char;
comb3_18=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*NUMBER VERIFIED OVER TIME GRAPH*/
ods pdf startpage=yes;

DATA TimeTrendAll;
INPUT Site Month NumVerified;
CARDS;
531629870 10 2
531629870 11 7
531629870 12 24
531629870 13 44
531629870 14 57
531629870 15 80
531629870 16 104
531629870 17 161
531629870 18 202
531629870 19 269
531629870 20 428
531629870 21 518
657167265 8 8
657167265 9 8
657167265 10 9
657167265 11 12
657167265 12 14
657167265 13 15
657167265 14 22
657167265 15 35
657167265 16 36
657167265 17 42
657167265 18 65
657167265 19 85
657167265 20 139
657167265 21 178
303349821 11 3
303349821 12 6
303349821 13 6
303349821 14 7
303349821 15 9
303349821 16 29
303349821 17 48
303349821 18 74
303349821 19 96
303349821 20 162
303349821 21 234
125001209 14 8
125001209 15 16
125001209 16 27
125001209 17 62
125001209 18 138
125001209 19 215
125001209 20 356
125001209 21 499
452412599 15 5
452412599 16 9
452412599 17 50
452412599 18 149
452412599 19 250
452412599 20 419
452412599 21 536
327912200 15 1
327912200 16 4
327912200 17 12
327912200 18 56
327912200 19 91
327912200 20 139
327912200 21 180
300267574 15 4
300267574 16 13
300267574 17 19
300267574 18 39
300267574 19 59
300267574 20 97
300267574 21 136
548392715 16 4
548392715 17 13
548392715 18 31
548392715 19 44
548392715 20 67
548392715 21 97
809703864 18 13
809703864 19 25
809703864 20 87
809703864 21 102
;
RUN;

PROC FORMAT;
VALUE MonthFmt 
			1 = "Jan21"
            2 = "Feb21"
			3 = "Mar21"
			4 = "Apr21"
			5 = "May21"
			6 = "Jun21"
			7 = "Jul21"
			8 = "Aug21"
			9 = "Sept21"
			10 = "Oct21"
			11 = "Nov21"
		    12 = "Dec21" 
			13 = "Jan22"
			14 = "Feb22"
			15 = "Mar22"
			16 = "Apr22"
			17 = "May22"
			18 = "June22"
			19 = "July22"
			20 = "Aug22"
			21 = "Sep22";
VALUE SiteNumFmt
			531629870 = "HealthPartners"
			548392715 = "Henry Ford Health System"
			125001209 = "Kaiser Permanente Colorado"
			327912200 = "Kaiser Permanente Georgia"
			300267574 = "Kaiser Permanente Hawaii"
			452412599 = "Kaiser Permanente Northwest"
			303349821 = "Marshfield Clinic Health System"
			657167265 = "Sanford Health"
			809703864 = "Unviersity of Chicago Medicine"
			517700004 = "National Cancer Institute"
			13 = "National Cancer Institute"
			181769837 = "Other";

DATA TimeTrendAll;
SET TimeTrendAll;
FORMAT Month MonthFmt. Site SiteNumFmt.;
RUN;

%_eg_conditional_dropds(WORK.SORTTEMPTABLESORTED_0001);
/* -------------------------------------------------------------------
   Sort data set WORK.TIMETREND
   ------------------------------------------------------------------- */
PROC SORT
	DATA=WORK.TIMETRENDAll(KEEP=Site Month NumVerified)
	OUT=WORK.SORTTEMPTABLESORTED_0001
	;
	BY Month;
RUN;
SYMBOL1
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	/*CV=CX179FD2*/
	LINE=2
	WIDTH=1
	COLOR=LIGHTSEAGREEN
	/*CI=BLACK*/;

SYMBOL2
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=BIP
	/*CI=Black*/;

SYMBOL3
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=BIO
	/*CI=Black*/;

SYMBOL4
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=DODGERBLUE
	/*CI=Black*/;

SYMBOL5
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=BIG
	/*CI=Black*/;

SYMBOL6
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=CRIMSON
	/*CI=Black*/;

SYMBOL7
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=BLACK
	/*CI=Black*/;

SYMBOL8
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=LIGRPR
	/*CI=Black*/;

SYMBOL9
	INTERPOL=JOIN
	HEIGHT=16pt
	VALUE=Diamond
	LINE=2
	WIDTH=1
	COLOR=FF6060
	/*CI=Black*/;

Axis1
	STYLE=1
	WIDTH=1
	MINOR=NONE
	LABEL=(   "Number Verified")
	order=(0 to 600 by 50);

Axis2
	STYLE=1
	WIDTH=1
	MINOR=NONE
	LABEL=(   "Month");

TITLE;
TITLE1 justify=center "                 Number Verified Over Time";
/*FOOTNOTE;*/
Legend1 label=(height=1 position=top justify=center)
across=1 down=3
position = (top left inside)
/*position=(bottom outside)*/
mode=protect;
PROC GPLOT DATA = WORK.SORTTEMPTABLESORTED_0001;
goptions horigin= 2.5in vorigin=1.5in;
goptions hsize= 12 in vsize=8 in; 
PLOT NumVerified * Month = site  /LEGEND=legend1
 	VAXIS=AXIS1

	HAXIS=AXIS2
	/*HREVERSE*/

FRAME;

/* -------------------------------------------------------------------
   End of task code
   ------------------------------------------------------------------- */
RUN; QUIT;

/*CANNOT BE VERIFIED*/
ods pdf startpage= yes;
Title Cannot Be Verified; 

*Creating 0/1 Var for Cannot Be Verified;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 THEN CannotBeVerifiedBin = 1;
ELSE CannotBeVerifiedBin = 0;
RUN;

*Cannot Be Verified;
proc report data=concept_ids SPLIT='00'x;
column sitechar 
TotRcrt CannotBeVerifiedBin pct1_19 comb1_19 n;
define sitechar / group center;
define CannotBeVerifiedBin /sum center noprint;
define TotRcrt /sum center noprint;
define pct1_19 / computed format=percent8.1 noprint center;
define comb1_19 / computed format=$20. 'Cannot Be Verified' style(column)=[cellwidth=1.4in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_19;
pct1_19=CannotBeVerifiedBin.sum/TotRcrt.sum;
endcomp;
 
compute comb1_19 / char;
comb1_19=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Reason Cannot Be Verified;

*Creating Reason Cannot Be Verified Vars;
*First Name Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_FNameMatch_v1r0 = 356674370 THEN FirstNameNotMatched = 1;
ELSE FirstNameNotMatched = 0;
RUN;

*Last Name Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_LNameMatch_v1r0 = 356674370 THEN LastNameNotMatched = 1;
ELSE LastNameNotMatched = 0;
RUN;

*DOB Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_DOBMatch_v1r0 = 356674370 THEN DOBNotMatched = 1;
ELSE DOBNotMatched = 0;
RUN;

*PIN Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_PINMatch_v1r0 = 356674370 THEN PINNotMatched = 1;
ELSE PINNotMatched = 0;
RUN;

*Token Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_TokenMatch_v1r0 = 356674370 THEN TokenNotMatched = 1;
ELSE TokenNotMatched = 0;
RUN;

*Zip Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_ZipMatch_v1r0 = 356674370 THEN ZipNotMatched = 1;
ELSE ZipNotMatched = 0;
RUN;

*Site Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_SiteMatch_v1r0 = 539025306 THEN SiteNotMatched = 1;
ELSE SiteNotMatched = 0;
RUN;

*Age Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_AgeMatch_v1r0 = 539025306 THEN AgeNotMatched = 1;
ELSE AgeNotMatched = 0;
RUN;

*Cancer Status Match;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 219863910 AND RcrtV_CStatusMatch_v1r0 = 539025306 THEN CancerNotMatched = 1;
ELSE CancerNotMatched = 0;
RUN;

ods pdf startpage=no;
Title Reason Cannot Be Verified; 
Proc odstext;
p "Reason Cannot Be Verified" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
proc report data=concept_ids SPLIT='00'x;
column sitechar 
TotRcrt FirstNameNotMatched pct1_20 comb1_20 TotRcrt
LastNameNotMatched pct2_20 comb2_20 TotRcrt
DOBNotMatched pct3_20 comb3_20 TotRcrt
PINNotMatched pct4_20 comb4_20 TotRcrt
TokenNotMatched pct5_20 comb5_20 TotRcrt
ZipNotMatched pct6_20 comb6_20 TotRcrt
SiteNotMatched pct7_20 comb7_20 TotRcrt 
AgeNotMatched pct8_20 comb8_20 TotRcrt
CancerNotMatched pct9_20 comb9_20 n;
define sitechar / group center;
define FirstNameNotMatched /sum center noprint;
define pct1_20 / computed format=percent8.1 noprint center;
define comb1_20 / computed format=$20. 'First Name Not Matched' style(column)=[cellwidth=0.75in] center;
define LastNameNotMatched /sum center noprint;
define pct2_20 / computed format=percent8.1 noprint center;
define comb2_20 / computed format=$20. 'Last Name Not Matched' style(column)=[cellwidth=0.75in] center;
define DOBNotMatched /sum noprint center;
define pct3_20 / computed format=percent8.1 noprint center;
define comb3_20 / computed format=$20. 'DOB Not Matched' style(column)=[cellwidth=0.75in] center;
define PINNotMatched /sum noprint center;
define pct4_20 / computed format=percent8.1 noprint center;
define comb4_20 / computed format=$20. 'PIN Not Matched' style(column)=[cellwidth=0.75in] center;
define TokenNotMatched /sum noprint center;
define pct5_20 / computed format=percent8.1 noprint center;
define comb5_20 / computed format=$20. 'Token Not Matched' style(column)=[cellwidth=0.75in] center;
define ZipNotMatched /sum noprint center;
define pct6_20 / computed format=percent8.1 noprint center;
define comb6_20 / computed format=$20. 'Zip Code Not Matched' style(column)=[cellwidth=0.75in] center;
define SiteNotMatched /sum noprint center;
define pct7_20 / computed format=percent8.1 noprint center;
define comb7_20 / computed format=$20. 'Site Not Matched' style(column)=[cellwidth=0.75in] center;
define AgeNotMatched /sum noprint center;
define pct8_20 / computed format=percent8.1 noprint center;
define comb8_20 / computed format=$20. 'Age Not Matched' style(column)=[cellwidth=0.75in] center;
define CancerNotMatched /sum noprint center;
define pct9_20 / computed format=percent8.1 noprint center;
define comb9_20 / computed format=$20. 'Cancer Status Not Matched' style(column)=[cellwidth=0.75in] center;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=0.75in] center;
define n /'Total Recruits' style(column)=[cellwidth=0.75in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_20;
pct1_20=FirstNameNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb1_20 / char;
comb1_20=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_20;
pct2_20=LastNameNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb2_20 / char;
comb2_20=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_20;
pct3_20=DOBNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb3_20 / char;
comb3_20=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_20;
pct4_20=PINNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb4_20 / char;
comb4_20=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_20;
pct5_20=TokenNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb5_20 / char;
comb5_20=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_20;
pct6_20=ZipNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb6_20 / char;
comb6_20=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_20;
pct7_20=SiteNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb7_20 / char;
comb7_20=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_20;
pct8_20=AgeNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb8_20 / char;
comb8_20=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_20;
pct9_20=CancerNotMatched.sum/TotRcrt.sum;
endcomp;
 
compute comb9_20 / char;
comb9_20=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*PREVIOUS CANCER*/
*Creating cancer 0/1 variable;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtUP_Cancer_v1r0 = 353358909 THEN CancerBin = 1;
ELSE CancerBin = 0;
RUN;

ods pdf startpage=yes;
Title Previous Cancer; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
TotRcrt CancerBin pct1_21 comb1_21 n;
define sitechar / group center;
define CancerBin /sum center noprint;
define pct1_21 / computed format=percent8.1 noprint center;
define comb1_21 / computed format=$20. 'Previous Cancer' style(column)=[cellwidth=1.4in] center;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=1in] center;
define n /'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_21;
pct1_21=CancerBin.sum/TotRcrt.sum;
endcomp;
 
compute comb1_21 / char;
comb1_21=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*OPT-OUT REASONS*/
*Creating 0/1 variables for reason for opt-out;
ods pdf startpage=now;
DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_busy = 353358909 THEN OptOutBusyBin = 1;
ELSE OptOutBusyBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_inter = 353358909 THEN OptOutInterBin = 1;
ELSE OptOutInterBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_priv = 353358909 THEN OptOutPrivBin = 1;
ELSE OptOutPrivBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_contacts = 353358909 THEN OptOutContactsBin = 1;
ELSE OptOutContactsBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_able = 353358909 THEN OptOutAbleBin = 1;
ELSE OptOutAbleBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_impt = 353358909 THEN OptOutImptBin = 1;
ELSE OptOutImptBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_partic = 353358909 THEN OptOutParticBin = 1;
ELSE OptOutParticBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_term = 353358909 THEN OptOutTermBin = 1;
ELSE OptOutTermBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_time = 353358909 THEN OptOutTimeBin = 1;
ELSE OptOutTimeBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_samples = 353358909 THEN OptOutSamplesBin = 1;
ELSE OptOutSamplesBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_comp = 353358909 THEN OptOutCompBin = 1;
ELSE OptOutCompBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_eligible = 353358909 THEN OptOutEligibleBin = 1;
ELSE OptOutEligibleBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_GenTest = 353358909 THEN OptOutGenTestBin = 1;
ELSE OptOutGenTestBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_health = 353358909 THEN OptOutHealthBin = 1;
ELSE OptOutHealthBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_access = 353358909 THEN OptOutAccessBin = 1;
ELSE OptOutAccessBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_online = 353358909 THEN OptOutOnlineBin = 1;
ELSE OptOutOnlineBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_concern = 353358909 THEN OptOutConcernBin = 1;
ELSE OptOutConcernBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyA = 353358909 THEN OptOutPrivacyABin = 1;
ELSE OptOutPrivacyABin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyB = 353358909 THEN OptOutPrivacyBBin = 1;
ELSE OptOutPrivacyBBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyC = 353358909 THEN OptOutPrivacyCBin = 1;
ELSE OptOutPrivacyCBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyD = 353358909 THEN OptOutPrivacyDBin = 1;
ELSE OptOutPrivacyDBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyE = 353358909 THEN OptOutPrivacyEBin = 1;
ELSE OptOutPrivacyEBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyF = 353358909 THEN OptOutPrivacyFBin = 1;
ELSE OptOutPrivacyFBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyG = 353358909 THEN OptOutPrivacyGBin = 1;
ELSE OptOutPrivacyGBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyH = 353358909 THEN OptOutPrivacyHBin = 1;
ELSE OptOutPrivacyHBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyI = 353358909 THEN OptOutPrivacyIBin = 1;
ELSE OptOutPrivacyIBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyJ = 353358909 THEN OptOutPrivacyJBin = 1;
ELSE OptOutPrivacyJBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyK = 353358909 THEN OptOutPrivacyKBin = 1;
ELSE OptOutPrivacyKBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_PrivacyL = 353358909 THEN OptOutPrivacyLBin = 1;
ELSE OptOutPrivacyLBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_Covid = 353358909 THEN OptOutCovidBin = 1;
ELSE OptOutCovidBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_MyChart = 353358909 THEN OptOutMyChartBin = 1;
ELSE OptOutMyChartBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_unable = 353358909 THEN OptOutUnableBin = 1;
ELSE OptOutUnableBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_none = 353358909 THEN OptOutNoneBin = 1;
ELSE OptOutNoneBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtSI_OptOut_v1r0_other = 353358909 THEN OptOutOtherBin = 1;
ELSE OptOutOtherBin = 0;
RUN;

*Creating 0/1 Variable for denominator for those that opted out;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_OptOut_v1r0 = 353358909 THEN OptOutYesBin = 1;
ELSE OptOutYesBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF OptOutYesBin = 1 THEN OptOutYesBin2 = 1;
ELSE OptOutYesBin2 = 0;
RUN;

*Part 1;
Title Pre-Consent Opt-Out Reasons Among Those that Opted Out; 
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
OptOutYesBin OptOutInterBin pct1_23 comb1_23 OptOutYesBin
OptOutBusyBin pct2_23 comb2_23 OptOutYesBin
OptOutOtherBin pct3_23 comb3_23 OptOutYesBin
OptOutNoneBin pct4_23 comb4_23 OptOutYesBin
OptOutParticBin pct5_23 comb5_23 OptOutYesBin
OptOutSamplesBin pct6_23 comb6_23 OptOutYesBin
OptOutTimeBin pct7_23 comb7_23 OptOutYesBin
OptOutHealthBin pct8_23 comb8_23 OptOutYesBin
OptOutMyChartBin pct9_23 comb9_23 OptOutYesBin
OptOutAbleBin pct10_23 comb10_23 OptOutYesBin
OptOutTermBin pct11_23 comb11_23 OptOutYesBin
OptOutEligibleBin pct12_23 comb12_23 OptOutYesBin
OptOutImptBin pct13_23 comb13_23 OptOutYesBin
OptOutUnableBin pct14_23 comb14_23 OptOutYesBin
OptOutPrivBin pct15_23 comb15_23 OptOutYesBin
OptOutPrivacyCBin pct16_23 comb16_23 OptOutYesBin
OptOutCompBin pct17_23 comb17_23 OptOutYesBin
OptOutOnlineBin pct18_23 comb18_23 OptOutYesBin
OptOutPrivacyBBin pct19_23 comb19_23 OptOutYesBin
OptOutGenTestBin pct20_23 comb20_23 OptOutYesBin
OptOutAccessBin pct21_23 comb21_23 OptOutYesBin
OptOutPrivacyABin pct22_23 comb22_23 OptOutYesBin
OptOutContactsBin pct23_23 comb23_23 OptOutYesBin
OptOutPrivacyHBin pct24_23 comb24_23 OptOutYesBin
OptOutConcernBin pct25_23 comb25_23 OptOutYesBin
OptOutPrivacyDBin pct26_23 comb26_23 OptOutYesBin
OptOutPrivacyEBin pct27_23 comb27_23 OptOutYesBin
OptOutPrivacyFBin pct28_23 comb28_23 OptOutYesBin
OptOutPrivacyGBin pct29_23 comb29_23 OptOutYesBin
OptOutPrivacyIBin pct30_23 comb30_23 OptOutYesBin
OptOutPrivacyJBin pct31_23 comb31_23 OptOutYesBin
OptOutPrivacyKBin pct32_23 comb32_23 OptOutYesBin
OptOutPrivacyLBin pct33_23 comb33_23 OptOutYesBin
OptOutCovidBin pct34_23 comb34_23 OptOutYesBin2; 
define sitechar / id group center flow;
define OptOutInterBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Not interested' style(column)=[cellwidth=1in] center;
define OptOutBusyBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Too busy/stressed to join' style(column)=[cellwidth=1in] center;
define OptOutOtherBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'Other reason(s)' style(column)=[cellwidth=1in] center;
define OptOutNoneBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center;
define OptOutParticBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'Does not want to participate in research' style(column)=[cellwidth=1in] center;
define OptOutSamplesBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Does not want to give biospecimen samples' style(column)=[cellwidth=1in] center;
define OptOutTimeBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Study takes too much time/asks for too much' style(column)=[cellwidth=1in] center;
define OptOutHealthBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Too sick/poor health to join' style(column)=[cellwidth=1in] center noprint;
define OptOutMyChartBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Refused MyChart Invitation' style(column)=[cellwidth=1in] center noprint;
define OptOutAbleBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center noprint;
define OptOutTermBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want to be in a long-term study' style(column)=[cellwidth=1in] center noprint;
define OptOutEligibleBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Does not think they are eligible' style(column)=[cellwidth=1in] center noprint;
define OptOutImptBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Does not think the research topic is important' style(column)=[cellwidth=1in] center noprint;
define OptOutUnableBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Person is unable to participate or deceased' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Concerned about Privacy' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyCBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Does not want to provide access to medical history information' style(column)=[cellwidth=1in] center noprint;
define OptOutCompBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Compensation to participate is not high enough' style(column)=[cellwidth=1in] center noprint;
define OptOutOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyBBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not want to complete surveys' style(column)=[cellwidth=1in] center noprint;
define OptOutGenTestBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Opposed to genetic testing' style(column)=[cellwidth=1in] center noprint;
define OptOutAccessBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Does not have reliable access to the internet' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyABin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Does not want to provide information online' style(column)=[cellwidth=1in] center noprint;
define OptOutContactsBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Too many contacts from the study' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyHBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center noprint;
define OptOutConcernBin /sum center noprint;
define pct25_23 / computed format=percent8.1 noprint center;
define comb25_23 / computed format=$20. 'Worried the study might find something concerning about them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyDBin /sum center noprint;
define pct26_23 / computed format=percent8.1 noprint center;
define comb26_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyEBin /sum center noprint;
define pct27_23 / computed format=percent8.1 noprint center;
define comb27_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyFBin /sum center noprint;
define pct28_23 / computed format=percent8.1 noprint center;
define comb28_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyGBin /sum center noprint;
define pct29_23 / computed format=percent8.1 noprint center;
define comb29_23 / computed format=$20. 'Worried information will not be secure' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyIBin /sum center noprint;
define pct30_23 / computed format=percent8.1 noprint center;
define comb30_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyJBin /sum center noprint;
define pct31_23 / computed format=percent8.1 noprint center;
define comb31_23 / computed format=$20. 'Worried that information could be used to discriminate against them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyKBin /sum center noprint;
define pct32_23 / computed format=percent8.1 noprint center;
define comb32_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyLBin /sum center noprint;
define pct33_23 / computed format=percent8.1 noprint center;
define comb33_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center noprint;
define OptOutCovidBin /sum center noprint;
define pct34_23 / computed format=percent8.1 noprint center;
define comb34_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center noprint;
define OptOutYesBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define OptOutYesBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_23;
pct1_23=OptOutInterBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=OptOutBusyBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=OptOutOtherBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=OptOutNoneBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=OptOutParticBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=OptOutSamplesBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=OptOutTimeBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=OptOutHealthBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=OptOutMyChartBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=OptOutAbleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=OptOutTermBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=OptOutEligibleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=OptOutImptBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=OptOutUnableBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=OptOutPrivBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=OptOutPrivacyCBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=OptOutCompBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=OptOutOnlineBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=OptOutPrivacyBBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=OptOutGenTestBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=OptOutAccessBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=OptOutPrivacyABin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=OptOutContactsBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=OptOutPrivacyHBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

compute pct25_23;
pct25_23=OptOutConcernBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb25_23 / char;
comb25_23=catt(strip(put(_c99_,8.)),' (',strip(put(_c100_,percent8.1)),')');
endcomp;

compute pct26_23;
pct26_23=OptOutPrivacyDBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb26_23 / char;
comb26_23=catt(strip(put(_c103_,8.)),' (',strip(put(_c104_,percent8.1)),')');
endcomp;

compute pct27_23;
pct27_23=OptOutPrivacyEBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb27_23 / char;
comb27_23=catt(strip(put(_c107_,8.)),' (',strip(put(_c108_,percent8.1)),')');
endcomp;

compute pct28_23;
pct28_23=OptOutPrivacyFBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb28_23 / char;
comb28_23=catt(strip(put(_c111_,8.)),' (',strip(put(_c112_,percent8.1)),')');
endcomp;

compute pct29_23;
pct29_23=OptOutPrivacyGBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb29_23 / char;
comb29_23=catt(strip(put(_c115_,8.)),' (',strip(put(_c116_,percent8.1)),')');
endcomp;

compute pct30_23;
pct30_23=OptOutPrivacyIBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb30_23 / char;
comb30_23=catt(strip(put(_c119_,8.)),' (',strip(put(_c120_,percent8.1)),')');
endcomp;

compute pct31_23;
pct31_23=OptOutPrivacyJBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb31_23 / char;
comb31_23=catt(strip(put(_c123_,8.)),' (',strip(put(_c124_,percent8.1)),')');
endcomp;

compute pct32_23;
pct32_23=OptOutPrivacyKBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb32_23 / char;
comb32_23=catt(strip(put(_c127_,8.)),' (',strip(put(_c128_,percent8.1)),')');
endcomp;

compute pct33_23;
pct33_23=OptOutPrivacyLBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb33_23 / char;
comb33_23=catt(strip(put(_c131_,8.)),' (',strip(put(_c132_,percent8.1)),')');
endcomp;

compute pct34_23;
pct34_23=OptOutCovidBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb34_23 / char;
comb34_23=catt(strip(put(_c135_,8.)),' (',strip(put(_c136_,percent8.1)),')');
endcomp;

rbreak after / summarize;

/*compute before _page_;
line @1 "(Continued)";
endcomp;*/

compute after;
sitechar="Total";
endcomp;

run;

*Part 2;
ods pdf startpage=never;
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
OptOutYesBin OptOutInterBin pct1_23 comb1_23 OptOutYesBin
OptOutBusyBin pct2_23 comb2_23 OptOutYesBin
OptOutOtherBin pct3_23 comb3_23 OptOutYesBin
OptOutNoneBin pct4_23 comb4_23 OptOutYesBin
OptOutParticBin pct5_23 comb5_23 OptOutYesBin
OptOutSamplesBin pct6_23 comb6_23 OptOutYesBin
OptOutTimeBin pct7_23 comb7_23 OptOutYesBin
OptOutHealthBin pct8_23 comb8_23 OptOutYesBin
OptOutMyChartBin pct9_23 comb9_23 OptOutYesBin
OptOutAbleBin pct10_23 comb10_23 OptOutYesBin
OptOutTermBin pct11_23 comb11_23 OptOutYesBin
OptOutEligibleBin pct12_23 comb12_23 OptOutYesBin
OptOutImptBin pct13_23 comb13_23 OptOutYesBin
OptOutUnableBin pct14_23 comb14_23 OptOutYesBin
OptOutPrivBin pct15_23 comb15_23 OptOutYesBin
OptOutPrivacyCBin pct16_23 comb16_23 OptOutYesBin
OptOutCompBin pct17_23 comb17_23 OptOutYesBin
OptOutOnlineBin pct18_23 comb18_23 OptOutYesBin
OptOutPrivacyBBin pct19_23 comb19_23 OptOutYesBin
OptOutGenTestBin pct20_23 comb20_23 OptOutYesBin
OptOutAccessBin pct21_23 comb21_23 OptOutYesBin
OptOutPrivacyABin pct22_23 comb22_23 OptOutYesBin
OptOutContactsBin pct23_23 comb23_23 OptOutYesBin
OptOutPrivacyHBin pct24_23 comb24_23 OptOutYesBin
OptOutConcernBin pct25_23 comb25_23 OptOutYesBin
OptOutPrivacyDBin pct26_23 comb26_23 OptOutYesBin
OptOutPrivacyEBin pct27_23 comb27_23 OptOutYesBin
OptOutPrivacyFBin pct28_23 comb28_23 OptOutYesBin
OptOutPrivacyGBin pct29_23 comb29_23 OptOutYesBin
OptOutPrivacyIBin pct30_23 comb30_23 OptOutYesBin
OptOutPrivacyJBin pct31_23 comb31_23 OptOutYesBin
OptOutPrivacyKBin pct32_23 comb32_23 OptOutYesBin
OptOutPrivacyLBin pct33_23 comb33_23 OptOutYesBin
OptOutCovidBin pct34_23 comb34_23 OptOutYesBin2; 
define sitechar / id group center flow;
define OptOutInterBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Not interested' style(column)=[cellwidth=1in] center noprint;
define OptOutBusyBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Too busy/stressed to join' style(column)=[cellwidth=1in] center noprint;
define OptOutOtherBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'Other reason(s)' style(column)=[cellwidth=1in] center noprint;
define OptOutNoneBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center noprint;
define OptOutParticBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'Does not want to participate in research' style(column)=[cellwidth=1in] center noprint;
define OptOutSamplesBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Does not want to give biospecimen samples' style(column)=[cellwidth=1in] center noprint;
define OptOutTimeBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Study takes too much time/asks for too much' style(column)=[cellwidth=1in] center noprint;
define OptOutHealthBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Too sick/poor health to join' style(column)=[cellwidth=1in] center;
define OptOutMyChartBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Refused MyChart Invitation' style(column)=[cellwidth=1in] center;
define OptOutAbleBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center;
define OptOutTermBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want to be in a long-term study' style(column)=[cellwidth=1in] center;
define OptOutEligibleBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Does not think they are eligible' style(column)=[cellwidth=1in] center;
define OptOutImptBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Does not think the research topic is important' style(column)=[cellwidth=1in] center;
define OptOutUnableBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Person is unable to participate or deceased' style(column)=[cellwidth=1in] center;
define OptOutPrivBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Concerned about Privacy' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyCBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Does not want to provide access to medical history information' style(column)=[cellwidth=1in] center noprint;
define OptOutCompBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Compensation to participate is not high enough' style(column)=[cellwidth=1in] center noprint;
define OptOutOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyBBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not want to complete surveys' style(column)=[cellwidth=1in] center noprint;
define OptOutGenTestBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Opposed to genetic testing' style(column)=[cellwidth=1in] center noprint;
define OptOutAccessBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Does not have reliable access to the internet' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyABin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Does not want to provide information online' style(column)=[cellwidth=1in] center noprint;
define OptOutContactsBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Too many contacts from the study' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyHBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center noprint;
define OptOutConcernBin /sum center noprint;
define pct25_23 / computed format=percent8.1 noprint center;
define comb25_23 / computed format=$20. 'Worried the study might find something concerning about them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyDBin /sum center noprint;
define pct26_23 / computed format=percent8.1 noprint center;
define comb26_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyEBin /sum center noprint;
define pct27_23 / computed format=percent8.1 noprint center;
define comb27_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyFBin /sum center noprint;
define pct28_23 / computed format=percent8.1 noprint center;
define comb28_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyGBin /sum center noprint;
define pct29_23 / computed format=percent8.1 noprint center;
define comb29_23 / computed format=$20. 'Worried information will not be secure' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyIBin /sum center noprint;
define pct30_23 / computed format=percent8.1 noprint center;
define comb30_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyJBin /sum center noprint;
define pct31_23 / computed format=percent8.1 noprint center;
define comb31_23 / computed format=$20. 'Worried that information could be used to discriminate against them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyKBin /sum center noprint;
define pct32_23 / computed format=percent8.1 noprint center;
define comb32_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyLBin /sum center noprint;
define pct33_23 / computed format=percent8.1 noprint center;
define comb33_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center noprint;
define OptOutCovidBin /sum center noprint;
define pct34_23 / computed format=percent8.1 noprint center;
define comb34_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center noprint;
define OptOutYesBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define OptOutYesBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_23;
pct1_23=OptOutInterBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=OptOutBusyBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=OptOutOtherBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=OptOutNoneBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=OptOutParticBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=OptOutSamplesBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=OptOutTimeBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=OptOutHealthBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=OptOutMyChartBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=OptOutAbleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=OptOutTermBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=OptOutEligibleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=OptOutImptBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=OptOutUnableBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=OptOutPrivBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=OptOutPrivacyCBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=OptOutCompBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=OptOutOnlineBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=OptOutPrivacyBBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=OptOutGenTestBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=OptOutAccessBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=OptOutPrivacyABin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=OptOutContactsBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=OptOutPrivacyHBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

compute pct25_23;
pct25_23=OptOutConcernBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb25_23 / char;
comb25_23=catt(strip(put(_c99_,8.)),' (',strip(put(_c100_,percent8.1)),')');
endcomp;

compute pct26_23;
pct26_23=OptOutPrivacyDBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb26_23 / char;
comb26_23=catt(strip(put(_c103_,8.)),' (',strip(put(_c104_,percent8.1)),')');
endcomp;

compute pct27_23;
pct27_23=OptOutPrivacyEBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb27_23 / char;
comb27_23=catt(strip(put(_c107_,8.)),' (',strip(put(_c108_,percent8.1)),')');
endcomp;

compute pct28_23;
pct28_23=OptOutPrivacyFBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb28_23 / char;
comb28_23=catt(strip(put(_c111_,8.)),' (',strip(put(_c112_,percent8.1)),')');
endcomp;

compute pct29_23;
pct29_23=OptOutPrivacyGBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb29_23 / char;
comb29_23=catt(strip(put(_c115_,8.)),' (',strip(put(_c116_,percent8.1)),')');
endcomp;

compute pct30_23;
pct30_23=OptOutPrivacyIBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb30_23 / char;
comb30_23=catt(strip(put(_c119_,8.)),' (',strip(put(_c120_,percent8.1)),')');
endcomp;

compute pct31_23;
pct31_23=OptOutPrivacyJBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb31_23 / char;
comb31_23=catt(strip(put(_c123_,8.)),' (',strip(put(_c124_,percent8.1)),')');
endcomp;

compute pct32_23;
pct32_23=OptOutPrivacyKBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb32_23 / char;
comb32_23=catt(strip(put(_c127_,8.)),' (',strip(put(_c128_,percent8.1)),')');
endcomp;

compute pct33_23;
pct33_23=OptOutPrivacyLBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb33_23 / char;
comb33_23=catt(strip(put(_c131_,8.)),' (',strip(put(_c132_,percent8.1)),')');
endcomp;

compute pct34_23;
pct34_23=OptOutCovidBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb34_23 / char;
comb34_23=catt(strip(put(_c135_,8.)),' (',strip(put(_c136_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Part 3;
ods pdf startpage=yes;
Title Pre-Consent Opt-Out Reasons Among Those that Opted Out (Continued);
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
OptOutYesBin OptOutInterBin pct1_23 comb1_23 OptOutYesBin
OptOutBusyBin pct2_23 comb2_23 OptOutYesBin
OptOutOtherBin pct3_23 comb3_23 OptOutYesBin
OptOutNoneBin pct4_23 comb4_23 OptOutYesBin
OptOutParticBin pct5_23 comb5_23 OptOutYesBin
OptOutSamplesBin pct6_23 comb6_23 OptOutYesBin
OptOutTimeBin pct7_23 comb7_23 OptOutYesBin
OptOutHealthBin pct8_23 comb8_23 OptOutYesBin
OptOutMyChartBin pct9_23 comb9_23 OptOutYesBin
OptOutAbleBin pct10_23 comb10_23 OptOutYesBin
OptOutTermBin pct11_23 comb11_23 OptOutYesBin
OptOutEligibleBin pct12_23 comb12_23 OptOutYesBin
OptOutImptBin pct13_23 comb13_23 OptOutYesBin
OptOutUnableBin pct14_23 comb14_23 OptOutYesBin
OptOutPrivBin pct15_23 comb15_23 OptOutYesBin
OptOutPrivacyCBin pct16_23 comb16_23 OptOutYesBin
OptOutCompBin pct17_23 comb17_23 OptOutYesBin
OptOutOnlineBin pct18_23 comb18_23 OptOutYesBin
OptOutPrivacyBBin pct19_23 comb19_23 OptOutYesBin
OptOutGenTestBin pct20_23 comb20_23 OptOutYesBin
OptOutAccessBin pct21_23 comb21_23 OptOutYesBin
OptOutPrivacyABin pct22_23 comb22_23 OptOutYesBin
OptOutContactsBin pct23_23 comb23_23 OptOutYesBin
OptOutPrivacyHBin pct24_23 comb24_23 OptOutYesBin
OptOutConcernBin pct25_23 comb25_23 OptOutYesBin
OptOutPrivacyDBin pct26_23 comb26_23 OptOutYesBin
OptOutPrivacyEBin pct27_23 comb27_23 OptOutYesBin
OptOutPrivacyFBin pct28_23 comb28_23 OptOutYesBin
OptOutPrivacyGBin pct29_23 comb29_23 OptOutYesBin
OptOutPrivacyIBin pct30_23 comb30_23 OptOutYesBin
OptOutPrivacyJBin pct31_23 comb31_23 OptOutYesBin
OptOutPrivacyKBin pct32_23 comb32_23 OptOutYesBin
OptOutPrivacyLBin pct33_23 comb33_23 OptOutYesBin
OptOutCovidBin pct34_23 comb34_23 OptOutYesBin2; 
define sitechar / id group center flow;
define OptOutInterBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Not interested' style(column)=[cellwidth=1in] center noprint;
define OptOutBusyBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Too busy/stressed to join' style(column)=[cellwidth=1in] center noprint;
define OptOutOtherBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'Other reason(s)' style(column)=[cellwidth=1in] center noprint;
define OptOutNoneBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center noprint;
define OptOutParticBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'Does not want to participate in research' style(column)=[cellwidth=1in] center noprint;
define OptOutSamplesBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Does not want to give biospecimen samples' style(column)=[cellwidth=1in] center noprint;
define OptOutTimeBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Study takes too much time/asks for too much' style(column)=[cellwidth=1in] center noprint;
define OptOutHealthBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Too sick/poor health to join' style(column)=[cellwidth=1in] center noprint;
define OptOutMyChartBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Refused MyChart Invitation' style(column)=[cellwidth=1in] center noprint;
define OptOutAbleBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center noprint;
define OptOutTermBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want to be in a long-term study' style(column)=[cellwidth=1in] center noprint;
define OptOutEligibleBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Does not think they are eligible' style(column)=[cellwidth=1in] center noprint;
define OptOutImptBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Does not think the research topic is important' style(column)=[cellwidth=1in] center noprint;
define OptOutUnableBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Person is unable to participate or deceased' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Concerned about Privacy' style(column)=[cellwidth=1in] center;
define OptOutPrivacyCBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Does not want to provide access to medical history information' style(column)=[cellwidth=1in] center;
define OptOutCompBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Compensation to participate is not high enough' style(column)=[cellwidth=1in] center;
define OptOutOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center;
define OptOutPrivacyBBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not want to complete surveys' style(column)=[cellwidth=1in] center;
define OptOutGenTestBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Opposed to genetic testing' style(column)=[cellwidth=1in] center;
define OptOutAccessBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Does not have reliable access to the internet' style(column)=[cellwidth=1in] center;
define OptOutPrivacyABin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Does not want to provide information online' style(column)=[cellwidth=1in] center noprint;
define OptOutContactsBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Too many contacts from the study' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyHBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center noprint;
define OptOutConcernBin /sum center noprint;
define pct25_23 / computed format=percent8.1 noprint center;
define comb25_23 / computed format=$20. 'Worried the study might find something concerning about them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyDBin /sum center noprint;
define pct26_23 / computed format=percent8.1 noprint center;
define comb26_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyEBin /sum center noprint;
define pct27_23 / computed format=percent8.1 noprint center;
define comb27_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyFBin /sum center noprint;
define pct28_23 / computed format=percent8.1 noprint center;
define comb28_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyGBin /sum center noprint;
define pct29_23 / computed format=percent8.1 noprint center;
define comb29_23 / computed format=$20. 'Worried information will not be secure' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyIBin /sum center noprint;
define pct30_23 / computed format=percent8.1 noprint center;
define comb30_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyJBin /sum center noprint;
define pct31_23 / computed format=percent8.1 noprint center;
define comb31_23 / computed format=$20. 'Worried that information could be used to discriminate against them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyKBin /sum center noprint;
define pct32_23 / computed format=percent8.1 noprint center;
define comb32_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyLBin /sum center noprint;
define pct33_23 / computed format=percent8.1 noprint center;
define comb33_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center noprint;
define OptOutCovidBin /sum center noprint;
define pct34_23 / computed format=percent8.1 noprint center;
define comb34_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center noprint;
define OptOutYesBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define OptOutYesBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_23;
pct1_23=OptOutInterBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=OptOutBusyBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=OptOutOtherBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=OptOutNoneBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=OptOutParticBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=OptOutSamplesBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=OptOutTimeBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=OptOutHealthBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=OptOutMyChartBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=OptOutAbleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=OptOutTermBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=OptOutEligibleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=OptOutImptBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=OptOutUnableBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=OptOutPrivBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=OptOutPrivacyCBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=OptOutCompBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=OptOutOnlineBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=OptOutPrivacyBBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=OptOutGenTestBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=OptOutAccessBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=OptOutPrivacyABin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=OptOutContactsBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=OptOutPrivacyHBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

compute pct25_23;
pct25_23=OptOutConcernBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb25_23 / char;
comb25_23=catt(strip(put(_c99_,8.)),' (',strip(put(_c100_,percent8.1)),')');
endcomp;

compute pct26_23;
pct26_23=OptOutPrivacyDBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb26_23 / char;
comb26_23=catt(strip(put(_c103_,8.)),' (',strip(put(_c104_,percent8.1)),')');
endcomp;

compute pct27_23;
pct27_23=OptOutPrivacyEBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb27_23 / char;
comb27_23=catt(strip(put(_c107_,8.)),' (',strip(put(_c108_,percent8.1)),')');
endcomp;

compute pct28_23;
pct28_23=OptOutPrivacyFBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb28_23 / char;
comb28_23=catt(strip(put(_c111_,8.)),' (',strip(put(_c112_,percent8.1)),')');
endcomp;

compute pct29_23;
pct29_23=OptOutPrivacyGBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb29_23 / char;
comb29_23=catt(strip(put(_c115_,8.)),' (',strip(put(_c116_,percent8.1)),')');
endcomp;

compute pct30_23;
pct30_23=OptOutPrivacyIBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb30_23 / char;
comb30_23=catt(strip(put(_c119_,8.)),' (',strip(put(_c120_,percent8.1)),')');
endcomp;

compute pct31_23;
pct31_23=OptOutPrivacyJBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb31_23 / char;
comb31_23=catt(strip(put(_c123_,8.)),' (',strip(put(_c124_,percent8.1)),')');
endcomp;

compute pct32_23;
pct32_23=OptOutPrivacyKBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb32_23 / char;
comb32_23=catt(strip(put(_c127_,8.)),' (',strip(put(_c128_,percent8.1)),')');
endcomp;

compute pct33_23;
pct33_23=OptOutPrivacyLBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb33_23 / char;
comb33_23=catt(strip(put(_c131_,8.)),' (',strip(put(_c132_,percent8.1)),')');
endcomp;

compute pct34_23;
pct34_23=OptOutCovidBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb34_23 / char;
comb34_23=catt(strip(put(_c135_,8.)),' (',strip(put(_c136_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Part 4;
ods pdf startpage=no;
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
OptOutYesBin OptOutInterBin pct1_23 comb1_23 OptOutYesBin
OptOutBusyBin pct2_23 comb2_23 OptOutYesBin
OptOutOtherBin pct3_23 comb3_23 OptOutYesBin
OptOutNoneBin pct4_23 comb4_23 OptOutYesBin
OptOutParticBin pct5_23 comb5_23 OptOutYesBin
OptOutSamplesBin pct6_23 comb6_23 OptOutYesBin
OptOutTimeBin pct7_23 comb7_23 OptOutYesBin
OptOutHealthBin pct8_23 comb8_23 OptOutYesBin
OptOutMyChartBin pct9_23 comb9_23 OptOutYesBin
OptOutAbleBin pct10_23 comb10_23 OptOutYesBin
OptOutTermBin pct11_23 comb11_23 OptOutYesBin
OptOutEligibleBin pct12_23 comb12_23 OptOutYesBin
OptOutImptBin pct13_23 comb13_23 OptOutYesBin
OptOutUnableBin pct14_23 comb14_23 OptOutYesBin
OptOutPrivBin pct15_23 comb15_23 OptOutYesBin
OptOutPrivacyCBin pct16_23 comb16_23 OptOutYesBin
OptOutCompBin pct17_23 comb17_23 OptOutYesBin
OptOutOnlineBin pct18_23 comb18_23 OptOutYesBin
OptOutPrivacyBBin pct19_23 comb19_23 OptOutYesBin
OptOutGenTestBin pct20_23 comb20_23 OptOutYesBin
OptOutAccessBin pct21_23 comb21_23 OptOutYesBin
OptOutPrivacyABin pct22_23 comb22_23 OptOutYesBin
OptOutContactsBin pct23_23 comb23_23 OptOutYesBin
OptOutPrivacyHBin pct24_23 comb24_23 OptOutYesBin
OptOutConcernBin pct25_23 comb25_23 OptOutYesBin
OptOutPrivacyDBin pct26_23 comb26_23 OptOutYesBin
OptOutPrivacyEBin pct27_23 comb27_23 OptOutYesBin
OptOutPrivacyFBin pct28_23 comb28_23 OptOutYesBin
OptOutPrivacyGBin pct29_23 comb29_23 OptOutYesBin
OptOutPrivacyIBin pct30_23 comb30_23 OptOutYesBin
OptOutPrivacyJBin pct31_23 comb31_23 OptOutYesBin
OptOutPrivacyKBin pct32_23 comb32_23 OptOutYesBin
OptOutPrivacyLBin pct33_23 comb33_23 OptOutYesBin
OptOutCovidBin pct34_23 comb34_23 OptOutYesBin2; 
define sitechar / id group center flow;
define OptOutInterBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Not interested' style(column)=[cellwidth=1in] center noprint;
define OptOutBusyBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Too busy/stressed to join' style(column)=[cellwidth=1in] center noprint;
define OptOutOtherBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'Other reason(s)' style(column)=[cellwidth=1in] center noprint;
define OptOutNoneBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center noprint;
define OptOutParticBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'Does not want to participate in research' style(column)=[cellwidth=1in] center noprint;
define OptOutSamplesBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Does not want to give biospecimen samples' style(column)=[cellwidth=1in] center noprint;
define OptOutTimeBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Study takes too much time/asks for too much' style(column)=[cellwidth=1in] center noprint;
define OptOutHealthBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Too sick/poor health to join' style(column)=[cellwidth=1in] center noprint;
define OptOutMyChartBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Refused MyChart Invitation' style(column)=[cellwidth=1in] center noprint;
define OptOutAbleBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center noprint;
define OptOutTermBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want to be in a long-term study' style(column)=[cellwidth=1in] center noprint;
define OptOutEligibleBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Does not think they are eligible' style(column)=[cellwidth=1in] center noprint;
define OptOutImptBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Does not think the research topic is important' style(column)=[cellwidth=1in] center noprint;
define OptOutUnableBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Person is unable to participate or deceased' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Concerned about Privacy' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyCBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Does not want to provide access to medical history information' style(column)=[cellwidth=1in] center noprint;
define OptOutCompBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Compensation to participate is not high enough' style(column)=[cellwidth=1in] center noprint;
define OptOutOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyBBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not want to complete surveys' style(column)=[cellwidth=1in] center noprint;
define OptOutGenTestBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Opposed to genetic testing' style(column)=[cellwidth=1in] center noprint;
define OptOutAccessBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Does not have reliable access to the internet' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyABin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Does not want to provide information online' style(column)=[cellwidth=1in] center;
define OptOutContactsBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Too many contacts from the study' style(column)=[cellwidth=1in] center;
define OptOutPrivacyHBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center;
define OptOutConcernBin /sum center noprint;
define pct25_23 / computed format=percent8.1 noprint center;
define comb25_23 / computed format=$20. 'Worried the study might find something concerning about them' style(column)=[cellwidth=1in] center;
define OptOutPrivacyDBin /sum center noprint;
define pct26_23 / computed format=percent8.1 noprint center;
define comb26_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center;
define OptOutPrivacyEBin /sum center noprint;
define pct27_23 / computed format=percent8.1 noprint center;
define comb27_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center;
define OptOutPrivacyFBin /sum center noprint;
define pct28_23 / computed format=percent8.1 noprint center;
define comb28_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center;
define OptOutPrivacyGBin /sum center noprint;
define pct29_23 / computed format=percent8.1 noprint center;
define comb29_23 / computed format=$20. 'Worried information will not be secure' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyIBin /sum center noprint;
define pct30_23 / computed format=percent8.1 noprint center;
define comb30_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyJBin /sum center noprint;
define pct31_23 / computed format=percent8.1 noprint center;
define comb31_23 / computed format=$20. 'Worried that information could be used to discriminate against them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyKBin /sum center noprint;
define pct32_23 / computed format=percent8.1 noprint center;
define comb32_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyLBin /sum center noprint;
define pct33_23 / computed format=percent8.1 noprint center;
define comb33_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center noprint;
define OptOutCovidBin /sum center noprint;
define pct34_23 / computed format=percent8.1 noprint center;
define comb34_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center noprint;
define OptOutYesBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define OptOutYesBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_23;
pct1_23=OptOutInterBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=OptOutBusyBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=OptOutOtherBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=OptOutNoneBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=OptOutParticBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=OptOutSamplesBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=OptOutTimeBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=OptOutHealthBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=OptOutMyChartBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=OptOutAbleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=OptOutTermBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=OptOutEligibleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=OptOutImptBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=OptOutUnableBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=OptOutPrivBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=OptOutPrivacyCBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=OptOutCompBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=OptOutOnlineBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=OptOutPrivacyBBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=OptOutGenTestBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=OptOutAccessBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=OptOutPrivacyABin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=OptOutContactsBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=OptOutPrivacyHBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

compute pct25_23;
pct25_23=OptOutConcernBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb25_23 / char;
comb25_23=catt(strip(put(_c99_,8.)),' (',strip(put(_c100_,percent8.1)),')');
endcomp;

compute pct26_23;
pct26_23=OptOutPrivacyDBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb26_23 / char;
comb26_23=catt(strip(put(_c103_,8.)),' (',strip(put(_c104_,percent8.1)),')');
endcomp;

compute pct27_23;
pct27_23=OptOutPrivacyEBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb27_23 / char;
comb27_23=catt(strip(put(_c107_,8.)),' (',strip(put(_c108_,percent8.1)),')');
endcomp;

compute pct28_23;
pct28_23=OptOutPrivacyFBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb28_23 / char;
comb28_23=catt(strip(put(_c111_,8.)),' (',strip(put(_c112_,percent8.1)),')');
endcomp;

compute pct29_23;
pct29_23=OptOutPrivacyGBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb29_23 / char;
comb29_23=catt(strip(put(_c115_,8.)),' (',strip(put(_c116_,percent8.1)),')');
endcomp;

compute pct30_23;
pct30_23=OptOutPrivacyIBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb30_23 / char;
comb30_23=catt(strip(put(_c119_,8.)),' (',strip(put(_c120_,percent8.1)),')');
endcomp;

compute pct31_23;
pct31_23=OptOutPrivacyJBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb31_23 / char;
comb31_23=catt(strip(put(_c123_,8.)),' (',strip(put(_c124_,percent8.1)),')');
endcomp;

compute pct32_23;
pct32_23=OptOutPrivacyKBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb32_23 / char;
comb32_23=catt(strip(put(_c127_,8.)),' (',strip(put(_c128_,percent8.1)),')');
endcomp;

compute pct33_23;
pct33_23=OptOutPrivacyLBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb33_23 / char;
comb33_23=catt(strip(put(_c131_,8.)),' (',strip(put(_c132_,percent8.1)),')');
endcomp;

compute pct34_23;
pct34_23=OptOutCovidBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb34_23 / char;
comb34_23=catt(strip(put(_c135_,8.)),' (',strip(put(_c136_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Part5;
ods pdf startpage=yes;
Title 'Pre-Consent Opt-Out Reasons Among Those that Opted Out (Continued)';
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
OptOutYesBin OptOutInterBin pct1_23 comb1_23 OptOutYesBin
OptOutBusyBin pct2_23 comb2_23 OptOutYesBin
OptOutOtherBin pct3_23 comb3_23 OptOutYesBin
OptOutNoneBin pct4_23 comb4_23 OptOutYesBin
OptOutParticBin pct5_23 comb5_23 OptOutYesBin
OptOutSamplesBin pct6_23 comb6_23 OptOutYesBin
OptOutTimeBin pct7_23 comb7_23 OptOutYesBin
OptOutHealthBin pct8_23 comb8_23 OptOutYesBin
OptOutMyChartBin pct9_23 comb9_23 OptOutYesBin
OptOutAbleBin pct10_23 comb10_23 OptOutYesBin
OptOutTermBin pct11_23 comb11_23 OptOutYesBin
OptOutEligibleBin pct12_23 comb12_23 OptOutYesBin
OptOutImptBin pct13_23 comb13_23 OptOutYesBin
OptOutUnableBin pct14_23 comb14_23 OptOutYesBin
OptOutPrivBin pct15_23 comb15_23 OptOutYesBin
OptOutPrivacyCBin pct16_23 comb16_23 OptOutYesBin
OptOutCompBin pct17_23 comb17_23 OptOutYesBin
OptOutOnlineBin pct18_23 comb18_23 OptOutYesBin
OptOutPrivacyBBin pct19_23 comb19_23 OptOutYesBin
OptOutGenTestBin pct20_23 comb20_23 OptOutYesBin
OptOutAccessBin pct21_23 comb21_23 OptOutYesBin
OptOutPrivacyABin pct22_23 comb22_23 OptOutYesBin
OptOutContactsBin pct23_23 comb23_23 OptOutYesBin
OptOutPrivacyHBin pct24_23 comb24_23 OptOutYesBin
OptOutConcernBin pct25_23 comb25_23 OptOutYesBin
OptOutPrivacyDBin pct26_23 comb26_23 OptOutYesBin
OptOutPrivacyEBin pct27_23 comb27_23 OptOutYesBin
OptOutPrivacyFBin pct28_23 comb28_23 OptOutYesBin
OptOutPrivacyGBin pct29_23 comb29_23 OptOutYesBin
OptOutPrivacyIBin pct30_23 comb30_23 OptOutYesBin
OptOutPrivacyJBin pct31_23 comb31_23 OptOutYesBin
OptOutPrivacyKBin pct32_23 comb32_23 OptOutYesBin
OptOutPrivacyLBin pct33_23 comb33_23 OptOutYesBin
OptOutCovidBin pct34_23 comb34_23 OptOutYesBin2; 
define sitechar / id group center flow;
define OptOutInterBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Not interested' style(column)=[cellwidth=1in] center noprint;
define OptOutBusyBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Too busy/stressed to join' style(column)=[cellwidth=1in] center noprint;
define OptOutOtherBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'Other reason(s)' style(column)=[cellwidth=1in] center noprint;
define OptOutNoneBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center noprint;
define OptOutParticBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'Does not want to participate in research' style(column)=[cellwidth=1in] center noprint;
define OptOutSamplesBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Does not want to give biospecimen samples' style(column)=[cellwidth=1in] center noprint;
define OptOutTimeBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Study takes too much time/asks for too much' style(column)=[cellwidth=1in] center noprint;
define OptOutHealthBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Too sick/poor health to join' style(column)=[cellwidth=1in] center noprint;
define OptOutMyChartBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Refused MyChart Invitation' style(column)=[cellwidth=1in] center noprint;
define OptOutAbleBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center noprint;
define OptOutTermBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want to be in a long-term study' style(column)=[cellwidth=1in] center noprint;
define OptOutEligibleBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Does not think they are eligible' style(column)=[cellwidth=1in] center noprint;
define OptOutImptBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Does not think the research topic is important' style(column)=[cellwidth=1in] center noprint;
define OptOutUnableBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Person is unable to participate or deceased' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Concerned about Privacy' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyCBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Does not want to provide access to medical history information' style(column)=[cellwidth=1in] center noprint;
define OptOutCompBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Compensation to participate is not high enough' style(column)=[cellwidth=1in] center noprint;
define OptOutOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyBBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not want to complete surveys' style(column)=[cellwidth=1in] center noprint;
define OptOutGenTestBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Opposed to genetic testing' style(column)=[cellwidth=1in] center noprint;
define OptOutAccessBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Does not have reliable access to the internet' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyABin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Does not want to provide information online' style(column)=[cellwidth=1in] center noprint;
define OptOutContactsBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Too many contacts from the study' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyHBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center noprint;
define OptOutConcernBin /sum center noprint;
define pct25_23 / computed format=percent8.1 noprint center;
define comb25_23 / computed format=$20. 'Worried the study might find something concerning about them' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyDBin /sum center noprint;
define pct26_23 / computed format=percent8.1 noprint center;
define comb26_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyEBin /sum center noprint;
define pct27_23 / computed format=percent8.1 noprint center;
define comb27_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyFBin /sum center noprint;
define pct28_23 / computed format=percent8.1 noprint center;
define comb28_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center noprint;
define OptOutPrivacyGBin /sum center noprint;
define pct29_23 / computed format=percent8.1 noprint center;
define comb29_23 / computed format=$20. 'Worried information will not be secure' style(column)=[cellwidth=1in] center;
define OptOutPrivacyIBin /sum center noprint;
define pct30_23 / computed format=percent8.1 noprint center;
define comb30_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center;
define OptOutPrivacyJBin /sum center noprint;
define pct31_23 / computed format=percent8.1 noprint center;
define comb31_23 / computed format=$20. 'Worried that information could be used to discriminate against them' style(column)=[cellwidth=1in] center;
define OptOutPrivacyKBin /sum center noprint;
define pct32_23 / computed format=percent8.1 noprint center;
define comb32_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center;
define OptOutPrivacyLBin /sum center noprint;
define pct33_23 / computed format=percent8.1 noprint center;
define comb33_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center;
define OptOutCovidBin /sum center noprint;
define pct34_23 / computed format=percent8.1 noprint center;
define comb34_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center;
define OptOutYesBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define OptOutYesBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_23;
pct1_23=OptOutInterBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=OptOutBusyBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=OptOutOtherBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=OptOutNoneBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=OptOutParticBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=OptOutSamplesBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=OptOutTimeBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=OptOutHealthBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=OptOutMyChartBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=OptOutAbleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=OptOutTermBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=OptOutEligibleBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=OptOutImptBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=OptOutUnableBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=OptOutPrivBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=OptOutPrivacyCBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=OptOutCompBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=OptOutOnlineBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=OptOutPrivacyBBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=OptOutGenTestBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=OptOutAccessBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=OptOutPrivacyABin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=OptOutContactsBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=OptOutPrivacyHBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

compute pct25_23;
pct25_23=OptOutConcernBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb25_23 / char;
comb25_23=catt(strip(put(_c99_,8.)),' (',strip(put(_c100_,percent8.1)),')');
endcomp;

compute pct26_23;
pct26_23=OptOutPrivacyDBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb26_23 / char;
comb26_23=catt(strip(put(_c103_,8.)),' (',strip(put(_c104_,percent8.1)),')');
endcomp;

compute pct27_23;
pct27_23=OptOutPrivacyEBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb27_23 / char;
comb27_23=catt(strip(put(_c107_,8.)),' (',strip(put(_c108_,percent8.1)),')');
endcomp;

compute pct28_23;
pct28_23=OptOutPrivacyFBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb28_23 / char;
comb28_23=catt(strip(put(_c111_,8.)),' (',strip(put(_c112_,percent8.1)),')');
endcomp;

compute pct29_23;
pct29_23=OptOutPrivacyGBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb29_23 / char;
comb29_23=catt(strip(put(_c115_,8.)),' (',strip(put(_c116_,percent8.1)),')');
endcomp;

compute pct30_23;
pct30_23=OptOutPrivacyIBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb30_23 / char;
comb30_23=catt(strip(put(_c119_,8.)),' (',strip(put(_c120_,percent8.1)),')');
endcomp;

compute pct31_23;
pct31_23=OptOutPrivacyJBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb31_23 / char;
comb31_23=catt(strip(put(_c123_,8.)),' (',strip(put(_c124_,percent8.1)),')');
endcomp;

compute pct32_23;
pct32_23=OptOutPrivacyKBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb32_23 / char;
comb32_23=catt(strip(put(_c127_,8.)),' (',strip(put(_c128_,percent8.1)),')');
endcomp;

compute pct33_23;
pct33_23=OptOutPrivacyLBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb33_23 / char;
comb33_23=catt(strip(put(_c131_,8.)),' (',strip(put(_c132_,percent8.1)),')');
endcomp;

compute pct34_23;
pct34_23=OptOutCovidBin.sum/OptOutYesBin.sum;
endcomp;
 
compute comb34_23 / char;
comb34_23=catt(strip(put(_c135_,8.)),' (',strip(put(_c136_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

ods pdf startpage=yes;
Title "Pre-Consent Opt-Out: Does Not Want To Join the Study For Other Reasons- Specified";
PROC PRINT label noobs DATA=Specify (DROP=COUNT PERCENT);


/*RECRUITMENT SUCCESS BY CAMPAIGN*/
ods pdf startpage=yes;
/*options bottommargin=0.05in topmargin=0.05in;*/
*Creating Campaign numerator and denominator vars;
*Random;
DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 926338735 THEN RandomBinNum = 1;
ELSE RandomBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 926338735 THEN RandomBinDen = 1;
ELSE RandomBinDen = 0;
RUN;

*Screening appointment;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 348281054 THEN ScreenBinNum = 1;
ELSE ScreenBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 348281054 THEN ScreenBinDen = 1;
ELSE ScreenBinDen = 0;
RUN;

*Non-screening appointment;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 324692899 THEN NoScreenBinNum = 1;
ELSE NoScreenBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 324692899 THEN NoScreenBinDen = 1;
ELSE NoScreenBinDen = 0;
RUN;

*Demographic Group;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 351257378 THEN DemogBinNum = 1;
ELSE DemogBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 351257378 THEN DemogBinDen = 1;
ELSE DemogBinDen = 0;
RUN;

*Aging out of study;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 647148178 THEN AgingBinNum = 1;
ELSE AgingBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 647148178 THEN AgingBinDen = 1;
ELSE AgingBinDen = 0;
RUN;

*Geographic group;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 834544960 THEN GeogBinNum = 1;
ELSE GeogBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 834544960 THEN GeogBinDen = 1;
ELSE GeogBinDen = 0;
RUN;

*Post-screening appointment;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 682916147 THEN PostScreenBinNum = 1;
ELSE PostScreenBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 682916147 THEN PostScreenBinDen = 1;
ELSE PostScreenBinDen = 0;
RUN;

*Technology adapters;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 153365143 THEN TechBinNum = 1;
ELSE TechBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 153365143 THEN TechBinDen = 1;
ELSE TechBinDen = 0;
RUN;

*Low-income/health professional shortage areas;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 663706936 THEN LowIncBinNum = 1;
ELSE LowIncBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 663706936 THEN LowIncBinDen = 1;
ELSE LowIncBinDen = 0;
RUN;

*Other;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 181769837 THEN OtherCampBinNum = 1;
ELSE OtherCampBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 181769837 THEN OtherCampBinDen = 1;
ELSE OtherCampBinDen = 0;
RUN;

*None of these apply;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 197316935 AND RcrtSI_RecruitType_v1r0 = 486306141 
AND RcrtSI_CampaignType_v1r0 = 398561594 THEN NoneBinNum = 1;
ELSE NoneBinNum = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_CampaignType_v1r0 = 398561594 THEN NoneBinDen = 1;
ELSE NoneBinDen = 0;
RUN;

*Creating Variable for Total in Campaign Type;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RandomBinDen = 1 THEN CampTotVar = 1;
ELSE IF ScreenBinDen = 1 THEN CampTotVar = 2;
ELSE IF NoScreenBinDen = 1 THEN CampTotVar = 3;
ELSE IF DemogBinDen = 1 THEN CampTotVar = 4;
ELSE IF AgingBinDen = 1 THEN CampTotVar = 5;
ELSE IF GeogBinDen = 1 THEN CampTotVar = 6;
ELSE IF PostScreenBinDen = 1 THEN CampTotVar = 7;
ELSE IF TechBinDen = 1 THEN CampTotVar = 8;
ELSE IF LowIncBinDen = 1 THEN CampTotVar = 9;
ELSE IF OtherCampBinDen = 1 THEN CampTotVar = 10;
ELSE IF NoneBinDen= 1 THEN CampTotVar = 11;
RUN;

PROC FORMAT;
VALUE CampToTVarFmt
	1 = "Random"
	2 = "Screening Appointment"
	3 = "Non-Screening Appointment"
	4 = "Demographic Group"
	5 = "Aging out of study"
	6 = "Geographic group"
	7 = "Post-screening appointment"
	8 = "Technology adapters"
	9 = "Low-income/health professional shortage areas"
	10 = "Other"
	11 = "None of these apply";
RUN;
DATA Work.Concept_ids; 
		SET Work.Concept_ids;
		LABEL  CampTotVar = "Total Active Recruits in Campaign";
		FORMAT CampTotVar CampTotVarFmt.;
RUN;

Title Recruitment Success By Campaign Among Active Recruits; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
RandomBinDen RandomBinNum pct1_22 comb1_22 ScreenBinDen
ScreenBinNum pct2_22 comb2_22 NoScreenBinDen
NoScreenBinNum pct3_22 comb3_22 DemogBinDen
DemogBinNum pct4_22 comb4_22 AgingBinDen
AgingBinNum pct5_22 comb5_22 GeogBinDen
GeogBinNum pct6_22 comb6_22 PostScreenBinDen
PostScreenBinNum pct7_22 comb7_22 TechBinDen 
TechBinNum pct8_22 comb8_22 LowIncBinDen
LowIncBinNum pct9_22 comb9_22 OtherCampBinDen
OtherCampBinNum pct10_22 comb10_22 NoneBinDen
NoneBinNum pct11_22 comb11_22 /*CampTotVar*/;
define sitechar / group style(column)=[cellwidth=1in] center;
define RandomBinDen /sum center noprint;
define RandomBinNum /sum center noprint;
define pct1_22 / computed format=percent8.1 noprint center;
define comb1_22 / computed format=$20. 'Random' style(column)=[cellwidth=0.65in] center;
define ScreenBinDen /sum center noprint;
define ScreenBinNum /sum center noprint;
define pct2_22 / computed format=percent8.1 noprint center;
define comb2_22 / computed format=$20. 'Screening Appointment' style(column)=[cellwidth=0.85in] center;
define NoScreenBinDen /sum noprint center;
define NoScreenBinNum /sum noprint center;
define pct3_22 / computed format=percent8.1 noprint center;
define comb3_22 / computed format=$20. 'Non-Screening Appointment' style(column)=[cellwidth=1.1in] center;
define DemogBinDen /sum noprint center;
define DemogBinNum /sum noprint center;
define pct4_22 / computed format=percent8.1 noprint center;
define comb4_22 / computed format=$20. 'Demographic Group' style(column)=[cellwidth=0.9in] center;
define AgingBinDen /sum noprint center;
define AgingBinNum /sum noprint center;
define pct5_22 / computed format=percent8.1 noprint center;
define comb5_22 / computed format=$20. 'Aging out of Study' style(column)=[cellwidth=0.7in] center;
define GeogBinDen /sum noprint center;
define GeogBinNum /sum noprint center;
define pct6_22 / computed format=percent8.1 noprint center;
define comb6_22 / computed format=$20. 'Geographic Group' style(column)=[cellwidth=0.8in] center;
define PostScreenBinDen /sum noprint center;
define PostScreenBinNum /sum noprint center;
define pct7_22 / computed format=percent8.1 noprint center;
define comb7_22 / computed format=$20. 'Post-Screening Appointment' style(column)=[cellwidth=1.1in] center;
define TechBinDen /sum noprint center;
define TechBinNum /sum noprint center;
define pct8_22 / computed format=percent8.1 noprint center;
define comb8_22 / computed format=$20. 'Technology Adapters' style(column)=[cellwidth=0.8in] center;
define LowIncBinDen /sum noprint center;
define LowIncBinNum /sum noprint center;
define pct9_22 / computed format=percent8.1 noprint center;
define comb9_22 / computed format=$20. 'Low-Income Areas' style(column)=[cellwidth=0.85in] center;
define OtherCampBinDen /sum noprint center;
define OtherCampBinNum /sum noprint center;
define pct10_22 / computed format=percent8.1 noprint center;
define comb10_22 / computed format=$20. 'Other' style(column)=[cellwidth=0.7in] center;
define NoneBinDen /sum noprint center;
define NoneBinNum /sum noprint center;
define pct11_22 / computed format=percent8.1 noprint center;
define comb11_22 / computed format=$20. 'None of these Apply' style(column)=[cellwidth=0.67in] center;
/*define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=0.7in] center;*/
/*define CampTotVar / sumwgt 'Total In Campaign' style(column)=[cellwidth=0.7in] center;*/ 
/* ^ gives me total of all the campaign types together per site */
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_22;
pct1_22=RandomBinNum.sum/RandomBinDen.sum;
endcomp;
 
compute comb1_22 / char;
comb1_22=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_22;
pct2_22=ScreenBinNum.sum/ScreenBinDen.sum;
endcomp;
 
compute comb2_22 / char;
comb2_22=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_22;
pct3_22=NoScreenBinNum.sum/NoScreenBinDen.sum;
endcomp;

compute comb3_22 / char;
comb3_22=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_22;
pct4_22=DemogBinNum.sum/DemogBinDen.sum;
endcomp;
 
compute comb4_22 / char;
comb4_22=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_22;
pct5_22=AgingBinNum.sum/AgingBinDen.sum;
endcomp;
 
compute comb5_22 / char;
comb5_22=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_22;
pct6_22=GeogBinNum.sum/GeogBinDen.sum;
endcomp;
 
compute comb6_22 / char;
comb6_22=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_22;
pct7_22=PostScreenBinNum.sum/PostScreenBinDen.sum;
endcomp;
 
compute comb7_22 / char;
comb7_22=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_22;
pct8_22=TechBinNum.sum/TechBinDen.sum;
endcomp;
 
compute comb8_22 / char;
comb8_22=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_22;
pct9_22=LowIncBinNum.sum/LowIncBinDen.sum;
endcomp;
 
compute comb9_22 / char;
comb9_22=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_22;
pct10_22=OtherCampBinNum.sum/OtherCampBinDen.sum;
endcomp;
 
compute comb10_22 / char;
comb10_22=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_22;
pct11_22=NoneBinNum.sum/NoneBinDen.sum;
endcomp;
 
compute comb11_22 / char;
comb11_22=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

*Including Table for Total for Denominators (Total Per Campaign Type);
ods pdf startpage=yes;
/*options bottommargin=0.05in topmargin=0.05in;*/
/*proc template;
define crosstabs Base.Freq.CrossTabFreqs;
define header myheader;
text 'Total Active Recruits in Campaign';
end;
end;
run; 
PROC FREQ DATA=Work.Concept_ids;
TABLES sitechar*CampTotVar /norow nocol nopercent;
TITLE "Total Active Recruits in Campaign";
RUN;*/
/*proc tabulate data = Work.Concept_ids; 
    class sitechar CampTotVar;
    tables sitechar,CampTotVar*n /style= [width=25cm];
run;*/

Proc odstext;
p "Table for Denominator (Total Number of Active Recruits in Campaign) on next page" /style=[fontsize=12pt just=left];
;
run;
Title Total Number of Active Recruits in Campaign;
proc report data=concept_ids SPLIT='00'x;
column sitechar RandomBinDen ScreenBinDen NoScreenBinDen DemogBinDen
AgingBinDen GeogBinDen PostScreenBinDen TechBinDen LowIncBinDen
OtherCampBinDen NoneBinDen;
define sitechar / group style(column)=[cellwidth=1in] center;
define RandomBinDen / 'Random' sum center style(column)=[cellwidth=0.65in] center;
define ScreenBinDen / 'Screening Appointment' sum center style(column)=[cellwidth=0.85in] center;
define NoScreenBinDen / 'Non-Screening Appointment' sum center style(column)=[cellwidth=1.1in] center; 
define DemogBinDen / 'Demographic Group' sum center style(column)=[cellwidth=0.9in] center;
define AgingBinDen / 'Aging out of Study' sum center style(column)=[cellwidth=0.7in] center;
define GeogBinDen / 'Geographic Group' sum center style(column)=[cellwidth=0.8in] center;
define PostScreenBinDen / 'Post-Screening Appointment' sum center style(column)=[cellwidth=1.1in] center; 
define TechBinDen / 'Technology Adapters' sum center style(column)=[cellwidth=0.8in] center;
define LowIncBinDen / 'Low-Income Areas' sum center style(column)=[cellwidth=0.85in] center;
define OtherCampBinDen / 'Other' sum center style(column)=[cellwidth=0.7in] center; 
define NoneBinDen / 'None of these Apply' sum center style(column)=[cellwidth=0.67in] center;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;
/*ods pdf startpage=never text= "(Continued)";*/


/*TIME TO COMPLETION OF ENROLLMENT*/
*Base Code run in import data step;

*Time from Active Recruit to Sign In;
ods pdf startpage=yes;
PROC PRINT noobs DATA=RecruitmentToSignInMin2 label style(table)={width=10in};
LABEL TmFrmActRecToSignIn2_Q1 = "Active Recruit to Sign In Q1"
	  TmFrmActRecToSignIn2_Median = "Active Recruit to Sign In Median"
      TmFrmActRecToSignIn2_Q3 = "Active Recruit to Sign In Q3";
FORMAT TmFrmActRecToSignIn2_Q1 mytimemin. TmFrmActRecToSignIn2_Median mytimemin. TmFrmActRecToSignIn2_Q3 mytimemin.;
VAR sitechar;
VAR RcrtSI_RecruitType_v1r0 /style=[cellwidth=1.4in];
VAR TmFrmActRecToSignIn2_Q1 TmFrmActRecToSignIn2_Median TmFrmActRecToSignIn2_Q3;
Title1 'Time to Completion of Enrollment';
Title2 ' ';
Title3 ' ';
Title4 'Time from Active Recruitment to Sign In';
WHERE RcrtSI_RecruitType_v1r0 = 486306141;
RUN;

*Time from Sign In to Consent;
ods pdf startpage=yes;
PROC PRINT noobs DATA=SignInToConsentMin2 label style(table)={width=10in};
*style(header obs obsheader)={color=bigb};
LABEL SignInToConsent2_Q1 = "Sign In to Consent Q1"
	  SignInToConsent2_Median = "Sign In to Consent Median"
	  SignInToConsent2_Q3 = "Sign In to Consent Q3";
FORMAT SignInToConsent2_Q1 mytimemin. SignInToConsent2_Median mytimemin. SignInToConsent2_Q3 mytimemin.;
Title 'Time from Sign In to Consent';
VAR sitechar;
VAR RcrtSI_RecruitType_v1r0 /style=[cellwidth=1.4in];
VAR SignInToConsent2_Q1 SignInToConsent2_Median SignInToConsent2_Q3;
RUN;

*Time from Consented to UP Submitted;
ods pdf startpage=yes;
PROC PRINT noobs DATA=ConsentTOUPMin2 label style(table)={width=10in};
LABEL ConsentToUP2_Q1 = "Consented to UP Submitted Q1"
	  ConsentToUp2_Median = "Consented to UP Submitted Median"
	  ConsentToUp2_Q3 = "Consented to UP Submitted Q3";
FORMAT ConsentToUP2_Q1 mytimemin. ConsentToUP2_Median mytimemin. ConsentToUP2_Q3 mytimemin.;
Title 'Time from Consented to UP Submitted';
VAR sitechar;
VAR RcrtSI_RecruitType_v1r0 /style=[cellwidth=1.4in];
VAR ConsentToUp2_Q1 ConsentToUp2_Median ConsentToUp2_Q3;
RUN;

*Time from UP Submitted to Verification Complete;
ods pdf startpage=yes;
PROC PRINT noobs DATA=UPTOVerifMin2 label style(table)={width=10in};
*style(header obs obsheader)={color=bigb};
LABEL UPToVerif2_Q1 = "UP Submitted to Verif Complete Q1"
	  UPToVerif2_Median = "UP Submitted to Verif Complete Median"
	  UPToVerif2_Q3 = "UP Submitted to Verif Complete Q3";
FORMAT UPToVerif2_Q1 mytimemin. UPToVerif2_Median mytimemin. UPToVerif2_Q3 mytimemin.;
VAR sitechar;
VAR RcrtSI_RecruitType_v1r0 /style=[cellwidth=1.25in];
VAR UPToVerif2_Q1;
VAR UPToVerif2_Median /style=[cellwidth=2.6in];
VAR UPToVerif2_Q3;
Title 'Time from UP Submitted to Verification Complete';
RUN;

*Total Enrollment Time;
ods pdf startpage=yes;
PROC PRINT noobs DATA=TotalEnrollmentMin2 label style(table)={width=9in};
LABEL TotalEnrollmentTime2_Q1 = "Total Enrollment Time Q1"
	  TotalEnrollmentTime2_Median = "Total Enrollment Time Median"
	  TotalEnrollmentTime2_Q3 = "Total Enrollment Time Q3";
FORMAT TotalEnrollmentTime2_Q1 mytimemin. TotalEnrollmentTime2_MEDIAN mytimemin. TotalEnrollmentTime2_Q3 mytimemin.;
VAR sitechar;
VAR RcrtSI_RecruitType_v1r0 /style=[cellwidth=1.25in];
VAR TotalEnrollmentTime2_Q1 TotalEnrollmentTime2_MEDIAN TotalEnrollmentTime2_Q3;
Title 'Total Enrollment Time';
RUN;

/*SIGN-IN MECHANISM USED FOR FIRST LOG ON*/
ods pdf startpage=yes;
/*options bottommargin=0.25in topmargin=0.25in;*/
*Creating 0/1 vars for sign-in mechanism;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtPC_Acnt_SignIn_v1r0 = 'google.com' OR RcrtPC_Acnt_SignIn_v1r0 = 943488874 THEN GoogleBin = 1;
ELSE GoogleBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtPC_Acnt_SignIn_v1r0 = 'password' OR RcrtPC_Acnt_SignIn_v1r0 = 101178950 THEN PasswordBin = 1;
ELSE PasswordBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtPC_Acnt_SignIn_v1r0 = 'phone' OR RcrtPC_Acnt_SignIn_v1r0 = 804918759 THEN PhoneBin = 1;
ELSE PhoneBin = 0;
RUN;

*Creating total signed in and consented var for those that have signed in (signed-in mech only populates for those that have consented);
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtSI_SignedIn_v1r0 = 353358909 AND RcrtCS_Consented_v1r0 = 353358909 THEN SignInTotBin = 1;
ELSE SignInTotBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF SignInTotBin = 1 THEN SignInTotBin2 = 1;
ELSE SignInTotBin2 = 0;
RUN;

Title Sign-In Mechanism Used for First Log On; 
proc report data=concept_ids SPLIT='00'x;
column sitechar 
SignInTotBin GoogleBin pct1_24 comb1_24 SignInTotBin
PasswordBin pct2_24 comb2_24 SignInTotBin
PhoneBin pct3_24 comb3_24 SignInTotBin2;
define sitechar / group center;
define GoogleBin /sum center noprint;
define pct1_24 / computed format=percent8.1 noprint center;
define comb1_24 / computed format=$20. 'Google.com' style(column)=[cellwidth=1in] center;
define PasswordBin /sum center noprint;
define pct2_24 / computed format=percent8.1 noprint center;
define comb2_24 / computed format=$20. 'Password' style(column)=[cellwidth=1in] center;
define PhoneBin /sum center noprint;
define pct3_24 / computed format=percent8.1 noprint center;
define comb3_24 / computed format=$20. 'Phone' style(column)=[cellwidth=1in] center;
define SignInTotBin / sum noprint 'Total Recruits that have Signed In and Consented' style(column)=[cellwidth=1in] center;
define SignInTotBin2 / sum 'Total Recruits that have Signed In and Consented' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_24;
pct1_24=GoogleBin.sum/SignInTotBin.sum;
endcomp;
 
compute comb1_24 / char;
comb1_24=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_24;
pct2_24=PasswordBin.sum/SignInTotBin.sum;
endcomp;
 
compute comb2_24 / char;
comb2_24=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_24;
pct3_24=PhoneBin.sum/SignInTotBin.sum;
endcomp;
 
compute comb3_24 / char;
comb3_24=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*HOW RECRUIT HEARD ABOUT STUDY*/
*Creating 0/1 variables for how recruit heard about study;
ods pdf startpage=now;
DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Email = 353358909 THEN EmailBinHeard = 1;
ELSE EmailBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Mail = 353358909 THEN MailBinHeard = 1;
ELSE MailBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Invite = 353358909 THEN InviteBinHeard = 1;
ELSE InviteBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Phone = 353358909 THEN PhoneBinHeard = 1;
ELSE PhoneBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Phys = 353358909 THEN PhysBinHeard = 1;
ELSE PhysBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Staff = 353358909 THEN StaffBinHeard = 1;
ELSE StaffBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_News = 353358909 THEN NewsBinHeard = 1;
ELSE NewsBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_HCNews = 353358909 THEN HCNewsBinHeard = 1;
ELSE HCNewsBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_HCSite = 353358909 THEN HCSiteBinHeard = 1;
ELSE HCSiteBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Web = 353358909 THEN WebBinHeard = 1;
ELSE WebBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Social = 353358909 THEN SocialBinHeard = 1;
ELSE SocialBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_TV = 353358909 THEN TVBinHeard = 1;
ELSE TVBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Video = 353358909 THEN VideoBinHeard = 1;
ELSE VideoBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Family = 353358909 THEN FamilyBinHeard = 1;
ELSE FamilyBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Member = 353358909 THEN MemberBinHeard = 1;
ELSE MemberBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Poster = 353358909 THEN PosterBinHeard = 1;
ELSE PosterBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Table = 353358909 THEN TableBinHeard = 1;
ELSE TableBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Hold = 353358909 THEN HoldBinHeard = 1;
ELSE HoldBinHeard = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF RcrtES_Aware_v1r0_Other = 353358909 THEN OtherBinHeard = 1;
ELSE OtherBinHeard = 0;
RUN;

*Part 1;
Title How Recruit Heard About Study; 
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
TotRcrt MailBinHeard pct1_25 comb1_25 TotRcrt
StaffBinHeard pct2_25 comb2_25 TotRcrt
EmailBinHeard pct3_25 comb3_25 TotRcrt
PhoneBinHeard pct4_25 comb4_25 TotRcrt
HCNewsBinHeard pct5_25 comb5_25 TotRcrt
OtherBinHeard pct6_25 comb6_25 TotRcrt
InviteBinHeard pct7_25 comb7_25 TotRcrt
FamilyBinHeard pct8_25 comb8_25 TotRcrt
PosterBinHeard pct9_25 comb9_25 TotRcrt
HCSiteBinHeard pct10_25 comb10_25 TotRcrt
PhysBinHeard pct11_25 comb11_25 TotRcrt
MemberBinHeard pct12_25 comb12_25 TotRcrt
NewsBinHeard  pct13_25 comb13_25 TotRcrt
WebBinHeard pct14_25 comb14_25 TotRcrt
SocialBinHeard pct15_25 comb15_25 TotRcrt
VideoBinHeard pct16_25 comb16_25 TotRcrt
TVBinHeard pct17_25 comb17_25 TotRcrt
TableBinHeard pct18_25 comb18_25 TotRcrt
HoldBinHeard pct19_25 comb19_25 n;
define sitechar / id group center flow;
define MailBinHeard /sum center noprint;
define pct1_25 / computed format=percent8.1 noprint center;
define comb1_25 / computed format=$20. 'Letter or brochure in mail' style(column)=[cellwidth=1in] center;
define StaffBinHeard /sum center noprint;
define pct2_25 / computed format=percent8.1 noprint center;
define comb2_25 / computed format=$20. 'Connect research staff at my health care system' style(column)=[cellwidth=1in] center;
define EmailBinHeard /sum center noprint;
define pct3_25 / computed format=percent8.1 noprint center;
define comb3_25 / computed format=$20. 'Email or text invitation' style(column)=[cellwidth=1in] center;
define PhoneBinHeard /sum center noprint;
define pct4_25 / computed format=percent8.1 noprint center;
define comb4_25 / computed format=$20. 'Phone call invitation' style(column)=[cellwidth=1in] center;
define HCNewsBinHeard /sum center noprint;
define pct5_25 / computed format=percent8.1 noprint center;
define comb5_25 / computed format=$20. 'Health care system newsletter' style(column)=[cellwidth=1in] center;
define OtherBinHeard /sum center noprint;
define pct6_25 / computed format=percent8.1 noprint center;
define comb6_25 / computed format=$20. 'Other' style(column)=[cellwidth=1in] center;
define InviteBinHeard /sum center noprint;
define pct7_25 / computed format=percent8.1 noprint center;
define comb7_25 / computed format=$20. 'Invitation through my patient portal' style(column)=[cellwidth=1in] center;
define FamilyBinHeard /sum center noprint;
define pct8_25 / computed format=percent8.1 noprint center;
define comb8_25 / computed format=$20. 'Family or friend' style(column)=[cellwidth=1in] center noprint;
define PosterBinHeard /sum center noprint;
define pct9_25 / computed format=percent8.1 noprint center;
define comb9_25 / computed format=$20. 'Poster, flyer, or sign at my health care system' style(column)=[cellwidth=1in] center noprint;
define HCSiteBinHeard /sum center noprint;
define pct10_25 / computed format=percent8.1 noprint center;
define comb10_25 / computed format=$20. 'Health care system website' style(column)=[cellwidth=1in] center noprint;
define PhysBinHeard /sum center noprint;
define pct11_25 / computed format=percent8.1 noprint center;
define comb11_25 / computed format=$20. 'Physician or other health care staff' style(column)=[cellwidth=1in] center noprint;
define MemberBinHeard /sum center noprint;
define pct12_25 / computed format=percent8.1 noprint center;
define comb12_25 / computed format=$20. 'Another Connect participant' style(column)=[cellwidth=1in] center noprint;
define NewsBinHeard /sum center noprint;
define pct13_25 / computed format=percent8.1 noprint center;
define comb13_25 / computed format=$20. 'News article or press release about Connect' style(column)=[cellwidth=1in] center noprint;
define WebBinHeard /sum center noprint;
define pct14_25 / computed format=percent8.1 noprint center;
define comb14_25 / computed format=$20. 'Connect website on Cancer.gov' style(column)=[cellwidth=1in] center noprint;
define SocialBinHeard /sum center noprint;
define pct15_25 / computed format=percent8.1 noprint center;
define comb15_25 / computed format=$20. 'Social media post' style(column)=[cellwidth=1in] center noprint;
define VideoBinHeard /sum center noprint;
define pct16_25 / computed format=percent8.1 noprint center;
define comb16_25 / computed format=$20. 'Video' style(column)=[cellwidth=1in] center noprint;
define TVBinHeard /sum center noprint;
define pct17_25 / computed format=percent8.1 noprint center;
define comb17_25 / computed format=$20. 'Local news, television, or radio station' style(column)=[cellwidth=1in] center noprint;
define TableBinHeard /sum center noprint;
define pct18_25 / computed format=percent8.1 noprint center;
define comb18_25 / computed format=$20. 'Connect table at public event' style(column)=[cellwidth=1in] center noprint;
define HoldBinHeard /sum center noprint;
define pct19_25 / computed format=percent8.1 noprint center;
define comb19_25 / computed format=$20. 'Recorded message' style(column)=[cellwidth=1in] center noprint;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_25;
pct1_25=MailBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb1_25 / char;
comb1_25=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_25;
pct2_25=StaffBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb2_25 / char;
comb2_25=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_25;
pct3_25=EmailBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb3_25 / char;
comb3_25=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_25;
pct4_25=PhoneBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb4_25 / char;
comb4_25=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_25;
pct5_25=HCNewsBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb5_25 / char;
comb5_25=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_25;
pct6_25=OtherBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb6_25 / char;
comb6_25=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_25;
pct7_25=InviteBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb7_25 / char;
comb7_25=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_25;
pct8_25=FamilyBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb8_25 / char;
comb8_25=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_25;
pct9_25=PosterBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb9_25 / char;
comb9_25=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_25;
pct10_25=HCSiteBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb10_25 / char;
comb10_25=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_25;
pct11_25=PhysBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb11_25 / char;
comb11_25=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_25;
pct12_25=MemberBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb12_25 / char;
comb12_25=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_25;
pct13_25=NewsBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb13_25 / char;
comb13_25=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_25;
pct14_25=WebBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb14_25 / char;
comb14_25=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_25;
pct15_25=SocialBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb15_25 / char;
comb15_25=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_25;
pct16_25=VideoBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb16_25 / char;
comb16_25=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_25;
pct17_25=TVBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb17_25 / char;
comb17_25=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_25;
pct18_25=TableBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb18_25 / char;
comb18_25=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_25;
pct19_25=HoldBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb19_25 / char;
comb19_25=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

rbreak after / summarize;

/*compute before _page_;
line @1 "(Continued)";
endcomp;*/

compute after;
sitechar="Total";
endcomp;

run;

*Part 2;
ods pdf startpage=never;
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
TotRcrt MailBinHeard pct1_25 comb1_25 TotRcrt
StaffBinHeard pct2_25 comb2_25 TotRcrt
EmailBinHeard pct3_25 comb3_25 TotRcrt
PhoneBinHeard pct4_25 comb4_25 TotRcrt
HCNewsBinHeard pct5_25 comb5_25 TotRcrt
OtherBinHeard pct6_25 comb6_25 TotRcrt
InviteBinHeard pct7_25 comb7_25 TotRcrt
FamilyBinHeard pct8_25 comb8_25 TotRcrt
PosterBinHeard pct9_25 comb9_25 TotRcrt
HCSiteBinHeard pct10_25 comb10_25 TotRcrt
PhysBinHeard pct11_25 comb11_25 TotRcrt
MemberBinHeard pct12_25 comb12_25 TotRcrt
NewsBinHeard  pct13_25 comb13_25 TotRcrt
WebBinHeard pct14_25 comb14_25 TotRcrt
SocialBinHeard pct15_25 comb15_25 TotRcrt
VideoBinHeard pct16_25 comb16_25 TotRcrt
TVBinHeard pct17_25 comb17_25 TotRcrt
TableBinHeard pct18_25 comb18_25 TotRcrt
HoldBinHeard pct19_25 comb19_25 n;
define sitechar / id group center flow;
define MailBinHeard /sum center noprint;
define pct1_25 / computed format=percent8.1 noprint center;
define comb1_25 / computed format=$20. 'Letter or brochure in mail' style(column)=[cellwidth=1in] center noprint;
define StaffBinHeard /sum center noprint;
define pct2_25 / computed format=percent8.1 noprint center;
define comb2_25 / computed format=$20. 'Connect research staff at my health care system' style(column)=[cellwidth=1in] center noprint;
define EmailBinHeard /sum center noprint;
define pct3_25 / computed format=percent8.1 noprint center;
define comb3_25 / computed format=$20. 'Email or text invitation' style(column)=[cellwidth=1in] center noprint;
define PhoneBinHeard /sum center noprint;
define pct4_25 / computed format=percent8.1 noprint center;
define comb4_25 / computed format=$20. 'Phone call invitation' style(column)=[cellwidth=1in] center noprint;
define HCNewsBinHeard /sum center noprint;
define pct5_25 / computed format=percent8.1 noprint center;
define comb5_25 / computed format=$20. 'Health care system newsletter' style(column)=[cellwidth=1in] center noprint;
define OtherBinHeard /sum center noprint;
define pct6_25 / computed format=percent8.1 noprint center;
define comb6_25 / computed format=$20. 'Other' style(column)=[cellwidth=1in] center noprint;
define InviteBinHeard /sum center noprint;
define pct7_25 / computed format=percent8.1 noprint center;
define comb7_25 / computed format=$20. 'Invitation through my patient portal' style(column)=[cellwidth=1in] center noprint;
define FamilyBinHeard /sum center noprint;
define pct8_25 / computed format=percent8.1 noprint center;
define comb8_25 / computed format=$20. 'Family or friend' style(column)=[cellwidth=1in] center;
define PosterBinHeard /sum center noprint;
define pct9_25 / computed format=percent8.1 noprint center;
define comb9_25 / computed format=$20. 'Poster, flyer, or sign at my health care system' style(column)=[cellwidth=1in] center;
define HCSiteBinHeard /sum center noprint;
define pct10_25 / computed format=percent8.1 noprint center;
define comb10_25 / computed format=$20. 'Health care system website' style(column)=[cellwidth=1in] center;
define PhysBinHeard /sum center noprint;
define pct11_25 / computed format=percent8.1 noprint center;
define comb11_25 / computed format=$20. 'Physician or other health care staff' style(column)=[cellwidth=1in] center;
define MemberBinHeard /sum center noprint;
define pct12_25 / computed format=percent8.1 noprint center;
define comb12_25 / computed format=$20. 'Another Connect participant' style(column)=[cellwidth=1in] center;
define NewsBinHeard /sum center noprint;
define pct13_25 / computed format=percent8.1 noprint center;
define comb13_25 / computed format=$20. 'News article or press release about Connect' style(column)=[cellwidth=1in] center;
define WebBinHeard /sum center noprint;
define pct14_25 / computed format=percent8.1 noprint center;
define comb14_25 / computed format=$20. 'Connect website on Cancer.gov' style(column)=[cellwidth=1in] center;
define SocialBinHeard /sum center noprint;
define pct15_25 / computed format=percent8.1 noprint center;
define comb15_25 / computed format=$20. 'Social media post' style(column)=[cellwidth=1in] center noprint;
define VideoBinHeard /sum center noprint;
define pct16_25 / computed format=percent8.1 noprint center;
define comb16_25 / computed format=$20. 'Video' style(column)=[cellwidth=1in] center noprint;
define TVBinHeard /sum center noprint;
define pct17_25 / computed format=percent8.1 noprint center;
define comb17_25 / computed format=$20. 'Local news, television, or radio station' style(column)=[cellwidth=1in] center noprint;
define TableBinHeard /sum center noprint;
define pct18_25 / computed format=percent8.1 noprint center;
define comb18_25 / computed format=$20. 'Connect table at public event' style(column)=[cellwidth=1in] center noprint;
define HoldBinHeard /sum center noprint;
define pct19_25 / computed format=percent8.1 noprint center;
define comb19_25 / computed format=$20. 'Recorded message' style(column)=[cellwidth=1in] center noprint;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_25;
pct1_25=MailBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb1_25 / char;
comb1_25=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_25;
pct2_25=StaffBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb2_25 / char;
comb2_25=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_25;
pct3_25=EmailBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb3_25 / char;
comb3_25=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_25;
pct4_25=PhoneBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb4_25 / char;
comb4_25=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_25;
pct5_25=HCNewsBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb5_25 / char;
comb5_25=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_25;
pct6_25=OtherBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb6_25 / char;
comb6_25=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_25;
pct7_25=InviteBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb7_25 / char;
comb7_25=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_25;
pct8_25=FamilyBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb8_25 / char;
comb8_25=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_25;
pct9_25=PosterBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb9_25 / char;
comb9_25=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_25;
pct10_25=HCSiteBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb10_25 / char;
comb10_25=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_25;
pct11_25=PhysBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb11_25 / char;
comb11_25=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_25;
pct12_25=MemberBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb12_25 / char;
comb12_25=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_25;
pct13_25=NewsBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb13_25 / char;
comb13_25=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_25;
pct14_25=WebBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb14_25 / char;
comb14_25=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_25;
pct15_25=SocialBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb15_25 / char;
comb15_25=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_25;
pct16_25=VideoBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb16_25 / char;
comb16_25=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_25;
pct17_25=TVBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb17_25 / char;
comb17_25=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_25;
pct18_25=TableBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb18_25 / char;
comb18_25=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_25;
pct19_25=HoldBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb19_25 / char;
comb19_25=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

rbreak after / summarize;

/*compute before _page_;
line @1 "(Continued)";
endcomp;*/

compute after;
sitechar="Total";
endcomp;

run;

*Part 3;
ods pdf startpage=yes;
Title How Recruit Heard About Study (Continued);
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
TotRcrt MailBinHeard pct1_25 comb1_25 TotRcrt
StaffBinHeard pct2_25 comb2_25 TotRcrt
EmailBinHeard pct3_25 comb3_25 TotRcrt
PhoneBinHeard pct4_25 comb4_25 TotRcrt
HCNewsBinHeard pct5_25 comb5_25 TotRcrt
OtherBinHeard pct6_25 comb6_25 TotRcrt
InviteBinHeard pct7_25 comb7_25 TotRcrt
FamilyBinHeard pct8_25 comb8_25 TotRcrt
PosterBinHeard pct9_25 comb9_25 TotRcrt
HCSiteBinHeard pct10_25 comb10_25 TotRcrt
PhysBinHeard pct11_25 comb11_25 TotRcrt
MemberBinHeard pct12_25 comb12_25 TotRcrt
NewsBinHeard  pct13_25 comb13_25 TotRcrt
WebBinHeard pct14_25 comb14_25 TotRcrt
SocialBinHeard pct15_25 comb15_25 TotRcrt
VideoBinHeard pct16_25 comb16_25 TotRcrt
TVBinHeard pct17_25 comb17_25 TotRcrt
TableBinHeard pct18_25 comb18_25 TotRcrt
HoldBinHeard pct19_25 comb19_25 n;
define sitechar / id group center flow;
define MailBinHeard /sum center noprint;
define pct1_25 / computed format=percent8.1 noprint center;
define comb1_25 / computed format=$20. 'Letter or brochure in mail' style(column)=[cellwidth=1in] center noprint;
define StaffBinHeard /sum center noprint;
define pct2_25 / computed format=percent8.1 noprint center;
define comb2_25 / computed format=$20. 'Connect research staff at my health care system' style(column)=[cellwidth=1in] center noprint;
define EmailBinHeard /sum center noprint;
define pct3_25 / computed format=percent8.1 noprint center;
define comb3_25 / computed format=$20. 'Email or text invitation' style(column)=[cellwidth=1in] center noprint;
define PhoneBinHeard /sum center noprint;
define pct4_25 / computed format=percent8.1 noprint center;
define comb4_25 / computed format=$20. 'Phone call invitation' style(column)=[cellwidth=1in] center noprint;
define HCNewsBinHeard /sum center noprint;
define pct5_25 / computed format=percent8.1 noprint center;
define comb5_25 / computed format=$20. 'Health care system newsletter' style(column)=[cellwidth=1in] center noprint;
define OtherBinHeard /sum center noprint;
define pct6_25 / computed format=percent8.1 noprint center;
define comb6_25 / computed format=$20. 'Other' style(column)=[cellwidth=1in] center noprint;
define InviteBinHeard /sum center noprint;
define pct7_25 / computed format=percent8.1 noprint center;
define comb7_25 / computed format=$20. 'Invitation through my patient portal' style(column)=[cellwidth=1in] center noprint;
define FamilyBinHeard /sum center noprint;
define pct8_25 / computed format=percent8.1 noprint center;
define comb8_25 / computed format=$20. 'Family or friend' style(column)=[cellwidth=1in] center noprint;
define PosterBinHeard /sum center noprint;
define pct9_25 / computed format=percent8.1 noprint center;
define comb9_25 / computed format=$20. 'Poster, flyer, or sign at my health care system' style(column)=[cellwidth=1in] center noprint;
define HCSiteBinHeard /sum center noprint;
define pct10_25 / computed format=percent8.1 noprint center;
define comb10_25 / computed format=$20. 'Health care system website' style(column)=[cellwidth=1in] center noprint;
define PhysBinHeard /sum center noprint;
define pct11_25 / computed format=percent8.1 noprint center;
define comb11_25 / computed format=$20. 'Physician or other health care staff' style(column)=[cellwidth=1in] center noprint;
define MemberBinHeard /sum center noprint;
define pct12_25 / computed format=percent8.1 noprint center;
define comb12_25 / computed format=$20. 'Another Connect participant' style(column)=[cellwidth=1in] center noprint;
define NewsBinHeard /sum center noprint;
define pct13_25 / computed format=percent8.1 noprint center;
define comb13_25 / computed format=$20. 'News article or press release about Connect' style(column)=[cellwidth=1in] center noprint;
define WebBinHeard /sum center noprint;
define pct14_25 / computed format=percent8.1 noprint center;
define comb14_25 / computed format=$20. 'Connect website on Cancer.gov' style(column)=[cellwidth=1in] center noprint;
define SocialBinHeard /sum center noprint;
define pct15_25 / computed format=percent8.1 noprint center;
define comb15_25 / computed format=$20. 'Social media post' style(column)=[cellwidth=1in] center;
define VideoBinHeard /sum center noprint;
define pct16_25 / computed format=percent8.1 noprint center;
define comb16_25 / computed format=$20. 'Video' style(column)=[cellwidth=1in] center;
define TVBinHeard /sum center noprint;
define pct17_25 / computed format=percent8.1 noprint center;
define comb17_25 / computed format=$20. 'Local news, television, or radio station' style(column)=[cellwidth=1in] center;
define TableBinHeard /sum center noprint;
define pct18_25 / computed format=percent8.1 noprint center;
define comb18_25 / computed format=$20. 'Connect table at public event' style(column)=[cellwidth=1in] center;
define HoldBinHeard /sum center noprint;
define pct19_25 / computed format=percent8.1 noprint center;
define comb19_25 / computed format=$20. 'Recorded message' style(column)=[cellwidth=1in] center;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=1in] center;
define n / 'Total Recruits' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_25;
pct1_25=MailBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb1_25 / char;
comb1_25=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_25;
pct2_25=StaffBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb2_25 / char;
comb2_25=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_25;
pct3_25=EmailBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb3_25 / char;
comb3_25=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_25;
pct4_25=PhoneBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb4_25 / char;
comb4_25=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_25;
pct5_25=HCNewsBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb5_25 / char;
comb5_25=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_25;
pct6_25=OtherBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb6_25 / char;
comb6_25=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_25;
pct7_25=InviteBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb7_25 / char;
comb7_25=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_25;
pct8_25=FamilyBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb8_25 / char;
comb8_25=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_25;
pct9_25=PosterBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb9_25 / char;
comb9_25=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_25;
pct10_25=HCSiteBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb10_25 / char;
comb10_25=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_25;
pct11_25=PhysBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb11_25 / char;
comb11_25=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_25;
pct12_25=MemberBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb12_25 / char;
comb12_25=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_25;
pct13_25=NewsBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb13_25 / char;
comb13_25=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_25;
pct14_25=WebBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb14_25 / char;
comb14_25=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_25;
pct15_25=SocialBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb15_25 / char;
comb15_25=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_25;
pct16_25=VideoBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb16_25 / char;
comb16_25=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_25;
pct17_25=TVBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb17_25 / char;
comb17_25=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_25;
pct18_25=TableBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb18_25 / char;
comb18_25=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_25;
pct19_25=HoldBinHeard.sum/TotRcrt.sum;
endcomp;
 
compute comb19_25 / char;
comb19_25=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

rbreak after / summarize;

/*compute before _page_;
line @1 "(Continued)";
endcomp;*/

compute after;
sitechar="Total";
endcomp;

run;

/*PROC TABULATE DATA=Work.Concept_ids;
CLASS sitechar MailBinHeard InviteBinHeard PhoneBinHeard PhysBinHeard StaffBinHeard NewsBinHeard 
HCNewsBinHeard HCSiteBinHeard WebBinHeard SocialBinHeard TVBinHeard VideoBinHeard FamilyBinHeard MemberBinHeard
PosterBinHeard TableBinHeard HoldBinHeard OtherBinHeard;
tables sitechar,(MailBinHeard InviteBinHeard PhoneBinHeard PhysBinHeard StaffBinHeard NewsBinHeard
HCNewsBinHeard HCSiteBinHeard WebBinHeard SocialBinHeard TVBinHeard VideoBinHeard FamilyBinHeard
MemberBinHeard PosterBinHeard TableBinHeard HoldBinHeard OtherBinHeard) /style= [width=25cm];
WHERE MailBinHeard = 1 AND InviteBinHeard = 1 AND PhoneBinHeard = 1 AND PhysBinHeard = 1 AND StaffBinHeard = 1
AND NewsBinHeard = 1 AND HCNewsBinHeard = 1 AND HCSiteBinHeard = 1 AND WebBinHeard = 1 AND SocialBinHeard = 1 
AND TVBinHeard = 1 AND VideoBinHeard = 1 AND FamilyBinHeard = 1 AND MemberBinHeard = 1 AND PosterBinHeard = 1 AND 
TableBinHeard = 1 AND HoldBinHeard = 1 AND OtherBinHeard = 1;
RUN;*/

/*OUT OF ACTIVE RECRUITS WHO DID NOT CONSENT, NUMBER AND PERCENT OF THOSE WHO HAVE MAX CONTACT ATTEMPTS*/
*Creating 0/1 Variable for Denominator;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtCS_Consented_v1r0 = 104430631 AND RcrtSI_RecruitType_v1r0 = 486306141 THEN ActNoConsentTot = 1;
ELSE ActNoConsentTot = 0;
RUN;

DATA Work.Concept_ids;
SET Work.Concept_ids;
IF ActNoConsentTot = 1 THEN ActNoConsentTot2 = 1;
ELSE ActNoConsentTot2 = 0;
RUN;

*Creating 0/1 Variable for Numerator;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtCS_Consented_v1r0 = 104430631 AND RcrtSI_RecruitType_v1r0 = 486306141 AND RcrtSI_MaxContcts_v1r0 = 353358909
THEN MaxContactsBin = 1;
ELSE MaxContactsBin = 0;
RUN;

ods pdf startpage=yes;
Title Out Of Active Recruits Who Did Not Consent, Number And Percent Of Those Who Have Max Contact Attempts Reached;
proc report data=concept_ids;
column sitechar
ActNoConsentTot MaxContactsBin pct1_26 comb1_26 ActNoConsentTot2;
define sitechar / id group center flow;
define MaxContactsBin /sum center noprint;
define pct1_26 / computed format=percent8.1 noprint center;
define comb1_26 / computed format=$20. 'Active Recruits Who Did Not Consent With Max Contact Attempts' style(column)=[cellwidth=1.5in] center;
define ActNoConsentTot / sum noprint 'Total Active Recruits Who Did Not Consent' style(column)=[cellwidth=1in] center;
define ActNoConsentTot2 / sum 'Total Active Recruits Who Did Not Consent' style(column)=[cellwidth=1.5in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_26;
pct1_26=MaxContactsBin.sum/ActNoConsentTot.sum;
endcomp;
 
compute comb1_26 / char;
comb1_26=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*OUTREACH TIMED OUT*/
*Creating Outreach Timed Out 0/1 Var;
ods pdf startpage=yes;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RcrtV_Verification_v1r0 = 160161595 THEN OutreachTimedOutBin = 1;
ELSE OutreachTimedOutBin = 0;
RUN;

Title Outreach Timed Out;
proc report data=concept_ids;
column sitechar
TotRcrt OutreachTimedOutBin pct1_27 comb1_27 n;
define sitechar / id group center flow;
define OutreachTimedOutBin /sum center noprint;
define pct1_27 / computed format=percent8.1 noprint center;
define comb1_27 / computed format=$20. 'Outreach Timed Out' style(column)=[cellwidth=1in] center;
define TotRcrt / sum noprint 'Total Recruits' style(column)=[cellwidth=1in] center;
define n /'Total Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;
 
compute pct1_27;
pct1_27=OutreachTimedOutBin.sum/TotRcrt.sum;
endcomp;
 
compute comb1_27 / char;
comb1_27=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*Incentive Tables*/
/*ods pdf startpage=yes;*/

*FIRST DISTRIBUTION TABLE: Distribution of Baseline Incentives Among Verified Participants from Chicago;

/*CREATING TABLE TO DELETE ONCE CHICAGO HAS PPL ELIGIBLE FOR INCENTIVE*/
/*data Incentive0;
input label x y Total;
cards;
1 0 0 0 
2 0 0 0
3 0 0 0
4 0 0 0
5 0 0 0
;
run;
 
PROC FORMAT;
VALUE labelfmt
	1 = "Incentive Issued"
	2 = "Incentive Not Issued"
	3 = "Incentive Declined"
	4 = "Incentive Not Declined"
	5 = "Total";
RUN;

DATA Incentive0;
SET Incentive0;
LABEL label = "Incentive Status";
FORMAT label labelfmt.;
RUN;

options validvarname=any;
data Incentive0;
set Incentive0;
rename label = 'Incentive Status'n;
rename x = 'Incentive Eligible'n;
rename y = 'Incentive Not Eligible'n;
rename Total = 'Total Verified Recruits'n;
run;

proc print data=Incentive0 noobs;
Title Distribution of Baseline Incentives Among Verified Participants from Chicago;
run;*/
/*COMMENT ABOVE OUT ONCE WE HAVE PPL IN CHICAGO THAT ARE ELIGIBLE FOR INCENTIVE*/

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

*Creating dataset to subset to chicago;
DATA IncentivesChicago;
SET Work.Concept_ids;
IF RcrtES_Site_v1r0 NE 809703864 THEN DELETE; 
ELSE IF RcrtV_Verification_v1r0 NE 197316935 THEN DELETE;
RUN;

*Creating character variable for incentive issued/incentive not issued/incentive declined/incentive not declined;
DATA IncentivesChicago;
length IncentiveChi1 $300;
SET IncentivesChicago;
IF BL_HDPaym_PaymIssued_v1r0 = 353358909 THEN IncentiveChi1 = "Incentive Issued";
ELSE IF BL_HDPaym_PaymIssued_v1r0 = 104430631 THEN IncentiveChi1= "Incentive Not Issued";
Label IncentiveChi1 = "Incentive Status";
RUN;

DATA IncentivesChicago;
length IncentiveChi2 $300;
SET IncentivesChicago;
IF BL_HDPaym_PaymRefused_v1r0 = 353358909 THEN IncentiveChi2 = "Incentive Declined";
ELSE IF BL_HDPaym_PaymRefused_v1r0 = 104430631 THEN IncentiveChi2 = "Incentive Not Declined";
Label IncentiveChi2 = "Incentive Status";
RUN;

*Creating binary 0/1 variable for Eligible for Payment;
DATA IncentivesChicago;
SET IncentivesChicago;
IF BL_SMPaym_PaymElig_v1r0 = 353358909 THEN PaymElig = 1;
ELSE PaymElig = 0;
RUN;

DATA IncentivesChicago;
SET IncentivesChicago;
IF BL_SMPaym_PaymElig_v1r0 = 104430631 THEN PaymNotElig = 1;
ELSE PaymNotElig = 0;
RUN;

*Adding format to get rows with 0's to show up;
proc format;
 value $incent (notsorted) 'Incentive Not Issued'='Incentive Not Issued'
 'Incentive Issued'='Incentive Issued';
run;
 
Title Distribution of Baseline Incentives Among Verified Participants from Chicago;
options missing='0';
proc report data=IncentivesChicago SPLIT='00'x completerows completecols nowd missing;
column IncentiveChi1
VerifiedRcrt PaymElig pct1_29 comb1_29 VerifiedRcrt
PaymNotElig pct2_29 comb2_29 VerifiedRcrt2;
define IncentiveChi1 / group center /*order=data*/ preloadfmt format=$incent.;
define PaymElig /sum center noprint;
define pct1_29 / computed format=percent8.1 noprint center;
define comb1_29 / computed format=$20. 'Incentive Eligible' style(column)=[cellwidth=1in] center;
define PaymNotElig /sum center noprint;
define pct2_29 / computed format=percent8.1 noprint center;
define comb2_29 / computed format=$20. 'Incentive Not Eligible' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_29;
pct1_29=PaymElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_29 / char;
comb1_29=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_29;
pct2_29=PaymNotElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_29 / char;
comb2_29=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
IncentiveChi1="Total";
endcomp;

run;

*Adding format to get rows with 0's to show up;
proc format;
 value $incenttwo (notsorted) 'Incentive Not Declined'='Incentive Not Declined'
 'Incentive Declined'='Incentive Declined';
run;

ods pdf startpage=no; 
Title Distribution of Baseline Incentives Among Verified Participants from Chicago;
options missing='0';
proc report data=IncentivesChicago SPLIT='00'x completerows completecols nowd missing;
column IncentiveChi2
VerifiedRcrt PaymElig pct1_29 comb1_29 VerifiedRcrt
PaymNotElig pct2_29 comb2_29 VerifiedRcrt2;
define IncentiveChi2 / group center /*order=data*/ preloadfmt format=$incenttwo.;
define PaymElig /sum center noprint;
define pct1_29 / computed format=percent8.1 noprint center;
define comb1_29 / computed format=$20. 'Incentive Eligible' style(column)=[cellwidth=1in] center;
define PaymNotElig /sum center noprint;
define pct2_29 / computed format=percent8.1 noprint center;
define comb2_29 / computed format=$20. 'Incentive Not Eligible' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_29;
pct1_29=PaymElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_29 / char;
comb1_29=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_29;
pct2_29=PaymNotElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_29 / char;
comb2_29=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
IncentiveChi2="Total";
endcomp;

run;

/*PROC MEANS TABLE FOR CHICAGO: 
Time from incentive eligible to incentive issued for Chicago*/
ods pdf startpage=no;
Proc odstext;
p "Time From Incentive Eligible to Incentive Issued for Chicago" /style=[fontweight=bold fontsize=11pt just=c];
;
run;
PROC PRINT DATA=IncentTimeChi label style(table)={width=9in} noobs;
LABEL IncentiveTimeChi_Min = "Incentive Eligible to Incentive Issued Min"
	  IncentiveTimeChi_Q1 = "Incentive Eligible to Incentive Issued Q1"
	  IncentiveTimeChi_Median = "Incentive Eligible to Incentive Issued Median"
	  IncentiveTimeChi_Mean = "Incentive Eligible to Incentive Issued Mean"
      IncentiveTimeChi_Q3 = "Incentive Eligible to Incentive Issued Q3"
	  IncentiveTimeChi_Max = "Incentive Eligible to Incentive Issued Max";
FORMAT IncentiveTimeChi_Min mytimemin. IncentiveTimeChi_Q1 mytimemin. IncentiveTimeChi_Median mytimemin. IncentiveTimeChi_Mean mytimemin.
IncentiveTimeChi_Q3 mytimemin. IncentiveTimeChi_Max mytimemin.;
VAR IncentiveTimeChi_Min IncentiveTimeChi_Q1 IncentiveTimeChi_Median IncentiveTimeChi_Mean IncentiveTimeChi_Q3 IncentiveTimeChi_Max;
Title 'Time from incentive eligible to incentive issued for Chicago';
RUN;

ods pdf startpage=no;
*SECOND DISTRIBUTION TABLE: Distribution of Baseline Incentives Among Verified Participants from All Other Sites;
Proc odstext;
p "Distribution of Baseline Incentives Among Verified Participants from NORC-Issued Incentives" /style=[fontweight=bold fontsize=11pt just=c];
;
run;

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

*Creating dataset to subset to all other participants excluding chicago;
DATA IncentivesAllOthSites;
SET Work.Concept_ids;
IF RcrtES_Site_v1r0 = 809703864 THEN DELETE; 
ELSE IF RcrtV_Verification_v1r0 NE 197316935 THEN DELETE;
RUN;

*Creating character variables for incentive issued/incentive not issued/incentive declined/incentive not declined;;
DATA IncentivesAllOthSites;
length IncentiveAll1 $300;
SET IncentivesAllOthSites;
IF BL_HDPaym_PaymIssued_v1r0 = 353358909 THEN IncentiveAll1 = "Incentive Issued";
ELSE IF BL_HDPaym_PaymIssued_v1r0 = 104430631 THEN IncentiveAll1 = "Incentive Not Issued";
Label IncentiveAll1 = "Incentive Status";
RUN;

DATA IncentivesAllOthSites;
length IncentiveAll2 $300;
SET IncentivesAllOthSites;
IF BL_HDPaym_PaymRefused_v1r0 = 353358909 THEN IncentiveAll2 = "Incentive Declined";
ELSE IF BL_HDPaym_PaymRefused_v1r0 = 104430631 THEN IncentiveAll2 = "Incentive Not Declined";
Label IncentiveAll2 = "Incentive Status";
RUN;

*Creating binary 0/1 variable for Eligible for Payment;
DATA IncentivesAllOthSites;
SET IncentivesAllOthSites;
IF BL_SMPaym_PaymElig_v1r0 = 353358909 THEN PaymElig = 1;
ELSE PaymElig = 0;
RUN;

DATA IncentivesAllOthSites;
SET IncentivesAllOthSites;
IF BL_SMPaym_PaymElig_v1r0 = 104430631 THEN PaymNotElig = 1;
ELSE PaymNotElig = 0;
RUN;

Title Distribution of Baseline Incentives Among Verified Participants from NORC-Issued Incentives;
proc report data=IncentivesAllOthSites SPLIT='00'x;
column IncentiveAll1
VerifiedRcrt PaymElig pct1_28 comb1_28 VerifiedRcrt
PaymNotElig pct2_28 comb2_28 VerifiedRcrt2;
define IncentiveAll1 / group center order=data;
define PaymElig /sum center noprint;
define pct1_28 / computed format=percent8.1 noprint center;
define comb1_28 / computed format=$20. 'Incentive Eligible' style(column)=[cellwidth=1in] center;
define PaymNotElig /sum center noprint;
define pct2_28 / computed format=percent8.1 noprint center;
define comb2_28 / computed format=$20. 'Incentive Not Eligible' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_28;
pct1_28=PaymElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_28 / char;
comb1_28=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_28;
pct2_28=PaymNotElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_28 / char;
comb2_28=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
IncentiveAll1="Total";
endcomp;

run;

proc report data=IncentivesAllOthSites SPLIT='00'x;
column IncentiveAll2
VerifiedRcrt PaymElig pct1_28 comb1_28 VerifiedRcrt
PaymNotElig pct2_28 comb2_28 VerifiedRcrt2;
define IncentiveAll2 / group center /*order=data*/;
define PaymElig /sum center noprint;
define pct1_28 / computed format=percent8.1 noprint center;
define comb1_28 / computed format=$20. 'Incentive Eligible' style(column)=[cellwidth=1in] center;
define PaymNotElig /sum center noprint;
define pct2_28 / computed format=percent8.1 noprint center;
define comb2_28 / computed format=$20. 'Incentive Not Eligible' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_28;
pct1_28=PaymElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_28 / char;
comb1_28=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_28;
pct2_28=PaymNotElig.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_28 / char;
comb2_28=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
IncentiveAll2="Total";
endcomp;

run;

/*PROC MEANS TABLE FOR ALL SITES EXCLUDING CHICAGO: 
Time from incentive eligible to incentive issued for NORC-issued incentives*/
/*Proc odstext;
p "Time From Incentive Eligible to Incentive Issued for NORC-Issued Incentives" /style=[fontweight=bold fontsize=11pt just=c];
;
run;*/
PROC PRINT DATA=IncentTimeAllOth label style(table)={width=9in} noobs;
LABEL IncentiveTimeAll_Min = "Incentive Eligible to Incentive Issued Min"
	  IncentiveTimeAll_Q1 = "Incentive Eligible to Incentive Issued Q1"
	  IncentiveTimeAll_Median = "Incentive Eligible to Incentive Issued Median"
	  IncentiveTimeAll_Mean = "Incentive Eligible to Incentive Issued Mean"
      IncentiveTimeAll_Q3 = "Incentive Eligible to Incentive Issued Q3"
	  IncentiveTimeAll_Max = "Incentive Eligible to Incentive Issued Max";
FORMAT IncentiveTimeAll_Min mytimemin. IncentiveTimeAll_Q1 mytimemin. IncentiveTimeAll_Median mytimemin. IncentiveTimeAll_Mean mytimemin.
IncentiveTimeAll_Q3 mytimemin. IncentiveTimeAll_Max mytimemin.;
VAR IncentiveTimeAll_Min IncentiveTimeAll_Q1 IncentiveTimeAll_Median IncentiveTimeAll_Mean IncentiveTimeAll_Q3 IncentiveTimeAll_Max;
Title 'Time From Incentive Eligible to Incentive Issued for NORC-Issued Incentives';
RUN;


/*REFUSALS AND WITHDRAWALS AMONG ALL VERIFIED PARTICIPANTS*/
ods pdf startpage=yes;

Title Refusals and Withdrawals Among All Verified Participants; 
proc report data=concept_ids;
column sitechar 
VerifiedRcrt HIPAARevVer pct1_12 comb1_12 VerifiedRcrt
WdConsentVer pct2_12 comb2_12 VerifiedRcrt
DestroyDataVer pct3_12 comb3_12 VerifiedRcrt
RefActivePartVerified pct4_12 comb4_12 VerifiedRcrt2;
define sitechar / group center;
define HIPAARevVer /sum center noprint;
define pct1_12 / computed format=percent8.1 noprint center;
define comb1_12 / computed format=$20. 'Revoked HIPAA Authorization' style(column)=[cellwidth=1in] center;
define WdConsentVer /sum center noprint;
define pct2_12 / computed format=percent8.1 noprint center;
define comb2_12 / computed format=$20. 'Withdrew Consent' style(column)=[cellwidth=1in] center;
define DestroyDataVer /sum noprint center;
define pct3_12 / computed format=percent8.1 noprint center;
define comb3_12 / computed format=$20. 'Data Destruction Requested' style(column)=[cellwidth=1in] center;
define RefActivePartVerified /sum noprint center;
define pct4_12 / computed format=percent8.1 noprint center;
define comb4_12 / computed format=$20. 'Full Refusal of Active Participation' style(column)=[cellwidth=1in] center;
define VerifiedRcrt / sum noprint 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
define VerifiedRcrt2 / sum 'Total Verified Recruits' style(column)=[cellwidth=1in] center;
WHERE RcrtSI_RecruitType_v1r0 NE 180583933;

compute pct1_12;
pct1_12=HIPAARevVer.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb1_12 / char;
comb1_12=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_12;
pct2_12=WdConsentVer.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb2_12 / char;
comb2_12=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_12;
pct3_12=DestroyDataVer.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb3_12 / char;
comb3_12=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_12;
pct4_12=RefActivePartVerified.sum/VerifiedRcrt.sum;
endcomp;
 
compute comb4_12 / char;
comb4_12=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

rbreak after / summarize;

compute after;
sitechar="Total";
endcomp;

run;

/*REFUSAL/WITHDRAWAL REASONS COUNT*/
*Creating 0/1 variables for reason for refusal/withdrawal;
ods pdf startpage=yes;
DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_NotInterested_v1r0 = 353358909 THEN RefWdNoInterestBin = 1;
ELSE RefWdNoInterestBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_TooMuchTime_v1r0 = 353358909 THEN RefWdMuchTimeBin = 1;
ELSE RefWdMuchTimeBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_Payment_v1r0 = 353358909 THEN RefWdPaymentBin = 1;
ELSE RefWdPaymentBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_Sick_v1r0 = 353358909 THEN RefWdSickBin = 1;
ELSE RefWdSickBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_NoInternet_v1r0 = 353358909 THEN RefWdInternetBin = 1;
ELSE RefWdInternetBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_WorriedResults_v1r0 = 353358909 THEN RefWdWorriedResBin = 1;
ELSE RefWdWorriedResBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_Worried_v1r0 = 353358909 THEN RefWdWorriedBin = 1;
ELSE RefWdWorriedBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_Privacy_v1r0 = 353358909 THEN RefWdPrivacyBin = 1;
ELSE RefWdPrivacyBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyB_v1r0 = 353358909 THEN RefWdPrivacyBBin = 1;
ELSE RefWdPrivacyBBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyC_v1r0 = 353358909 THEN RefWdPrivacyCBin = 1;
ELSE RefWdPrivacyCBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyD_v1r0 = 353358909 THEN RefWdPrivacyDBin = 1;
ELSE RefWdPrivacyDBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyE_v1r0 = 353358909 THEN RefWdPrivacyEBin = 1;
ELSE RefWdPrivacyEBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyF_v1r0 = 353358909 THEN RefWdPrivacyFBin = 1;
ELSE RefWdPrivacyFBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyG_v1r0 = 353358909 THEN RefWdPrivacyGBin = 1;
ELSE RefWdPrivacyGBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyH_v1r0 = 353358909 THEN RefWdPrivacyHBin = 1;
ELSE RefWdPrivacyHBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyI_v1r0 = 353358909 THEN RefWdPrivacyIBin = 1;
ELSE RefWdPrivacyIBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_PrivacyJ_v1r0 = 353358909 THEN RefWdPrivacyJBin = 1;
ELSE RefWdPrivacyJBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_Online_v1r0 = 353358909 THEN RefWdOnlineBin = 1;
ELSE RefWdOnlineBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_DislikeOnline_v1r0 = 353358909 THEN RefWdDislikeOnlineBin = 1;
ELSE RefWdDislikeOnlineBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_COVID_v1r0 = 353358909 THEN RefWdCOVIDBin = 1;
ELSE RefWdCOVIDBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_Unable_v1r0 = 353358909 THEN RefWdUnableBin = 1;
ELSE RefWdUnableBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_Incarcerated_v1r0 = 353358909 THEN RefWdIncarceratedBin = 1;
ELSE RefWdIncarceratedBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_OthRsn_v1r0 = 353358909 THEN RefWdOthRsnBin = 1;
ELSE RefWdOthRsnBin = 0;
RUN;

DATA Work.Concept_ids;
SET Work.CONCEPT_IDS;
IF HdRef_NotGiven_v1r0 = 353358909 THEN RefWdNotGivenBin = 1;
ELSE RefWdNotGivenBin = 0;
RUN;

*Creating Refusal/Withdrawal 0/1 variable;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF HdWd_WdConsent_v1r0 = 353358909 OR HdWd_SuspendContact_v1r0 = 353358909 OR HdWd_Activepart_v1r0 = 353358909
OR HdWd_HIPAArevoked_v1r0 = 353358909 OR HdWd_Destroydata_v1r0 = 353358909 OR SMMet_PartStatus_v1r0 NE 208325815
OR SMMet_PartStatus_v1r0 NE .
THEN RefusalWithdrawalBin = 1;
ELSE RefusalWithdrawalBin = 0;

*Creating 0/1 Variable for denominator for those that refused/withdrew;
DATA Work.Concept_ids;
SET Work.Concept_ids;
IF RefusalWithdrawalBin = 1 THEN RefusalWithdrawalBin2 = 1;
ELSE RefusalWithdrawalBin2 = 0;
RUN;

*Part 1;
Title Reasons for Refusal/Withdrawal; 
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
RefusalWithdrawalBin RefWdNotGivenBin pct1_23 comb1_23 RefusalWithdrawalBin
RefWdPrivacyJBin pct2_23 comb2_23 RefusalWithdrawalBin
RefWdNoInterestBin pct3_23 comb3_23 RefusalWithdrawalBin
RefWdSickBin pct4_23 comb4_23 RefusalWithdrawalBin
RefWdInternetBin pct5_23 comb5_23 RefusalWithdrawalBin
RefWdWorriedResBin pct6_23 comb6_23 RefusalWithdrawalBin
RefWdWorriedBin pct7_23 comb7_23 RefusalWithdrawalBin
RefWdPrivacyBin pct8_23 comb8_23 RefusalWithdrawalBin
RefWdPrivacyBBin pct9_23 comb9_23 RefusalWithdrawalBin
RefWdPrivacyCBin pct10_23 comb10_23 RefusalWithdrawalBin
RefWdPrivacyDBin pct11_23 comb11_23 RefusalWithdrawalBin
RefWdPrivacyEBin pct12_23 comb12_23 RefusalWithdrawalBin
RefWdPrivacyFBin pct13_23 comb13_23 RefusalWithdrawalBin
RefWdPrivacyGBin pct14_23 comb14_23 RefusalWithdrawalBin
RefWdPrivacyHBin pct15_23 comb15_23 RefusalWithdrawalBin
RefWdPrivacyIBin pct16_23 comb16_23 RefusalWithdrawalBin
RefWdMuchTimeBin pct17_23 comb17_23 RefusalWithdrawalBin
RefWdOnlineBin pct18_23 comb18_23 RefusalWithdrawalBin
RefWdDislikeOnlineBin pct19_23 comb19_23 RefusalWithdrawalBin
RefWdCOVIDBin pct20_23 comb20_23 RefusalWithdrawalBin 
RefWdUnableBin pct21_23 comb21_23 RefusalWithdrawalBin
RefWdIncarceratedBin pct22_23 comb22_23 RefusalWithdrawalBin
RefWdOthRsnBin pct23_23 comb23_23 RefusalWithdrawalBin
RefWdPaymentBin pct24_23 comb24_23 RefusalWithdrawalBin2;
define sitechar / id group center flow;
define RefWdNotGivenBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center;
define RefWdPrivacyJBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center;
define RefWdNoInterestBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'No longer interested in study' style(column)=[cellwidth=1in] center;
define RefWdSickBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Too sick' style(column)=[cellwidth=1in] center;
define RefWdInternetBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'No reliable access to internet' style(column)=[cellwidth=1in] center;
define RefWdWorriedResBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Worried about results' style(column)=[cellwidth=1in] center;
define RefWdWorriedBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Worried study might find something concerning about me' style(column)=[cellwidth=1in] center;
define RefWdPrivacyBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Concerned about privacy' style(column)=[cellwidth=1in] center;
define RefWdPrivacyBBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyCBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyDBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyEBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Worried information is not secure' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyFBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyGBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyHBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Worried that information could be used to discriminate' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyIBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center noprint;
define RefWdMuchTimeBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Too busy/Takes too much time' style(column)=[cellwidth=1in] center noprint;
define RefWdOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center noprint;
define RefWdDislikeOnlineBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center noprint;
define RefWdCOVIDBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center noprint;
define RefWdUnableBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Participant is now unable to participate' style(column)=[cellwidth=1in] center noprint;
define RefWdIncarceratedBin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Participant is incarcerated' style(column)=[cellwidth=1in] center noprint;
define RefWdOthRsnBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Other reasons' style(column)=[cellwidth=1in] center noprint;
define RefWdPaymentBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Payment is not great enough' style(column)=[cellwidth=1in] center noprint;
define RefusalWithdrawalBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define RefusalWithdrawalBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
/*WHERE RcrtSI_RecruitType_v1r0 NE 180583933;*/
 
compute pct1_23;
pct1_23=RefWdNotGivenBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=RefWdPrivacyJBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=RefWdNoInterestBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=RefWdSickBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=RefWdInternetBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=RefWdWorriedResBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=RefWdWorriedBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=RefWdPrivacyBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=RefWdPrivacyBBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=RefWdPrivacyCBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=RefWdPrivacyDBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=RefWdPrivacyEBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=RefWdPrivacyFBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=RefWdPrivacyGBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=RefWdPrivacyHBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=RefWdPrivacyIBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=RefWdMuchTimeBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=RefWdOnlineBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=RefWdDislikeOnlineBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=RefWdCOVIDBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=RefWdUnableBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=RefWdIncarceratedBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=RefWdOthRsnBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=RefWdPaymentBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

rbreak after / summarize;

/*compute before _page_;
line @1 "(Continued)";
endcomp;*/

compute after;
sitechar="Total";
endcomp;

run;

*Part 2;
Title Reasons for Refusal/Withdrawal Continued; 
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
RefusalWithdrawalBin RefWdNotGivenBin pct1_23 comb1_23 RefusalWithdrawalBin
RefWdPrivacyJBin pct2_23 comb2_23 RefusalWithdrawalBin
RefWdNoInterestBin pct3_23 comb3_23 RefusalWithdrawalBin
RefWdSickBin pct4_23 comb4_23 RefusalWithdrawalBin
RefWdInternetBin pct5_23 comb5_23 RefusalWithdrawalBin
RefWdWorriedResBin pct6_23 comb6_23 RefusalWithdrawalBin
RefWdWorriedBin pct7_23 comb7_23 RefusalWithdrawalBin
RefWdPrivacyBin pct8_23 comb8_23 RefusalWithdrawalBin
RefWdPrivacyBBin pct9_23 comb9_23 RefusalWithdrawalBin
RefWdPrivacyCBin pct10_23 comb10_23 RefusalWithdrawalBin
RefWdPrivacyDBin pct11_23 comb11_23 RefusalWithdrawalBin
RefWdPrivacyEBin pct12_23 comb12_23 RefusalWithdrawalBin
RefWdPrivacyFBin pct13_23 comb13_23 RefusalWithdrawalBin
RefWdPrivacyGBin pct14_23 comb14_23 RefusalWithdrawalBin
RefWdPrivacyHBin pct15_23 comb15_23 RefusalWithdrawalBin
RefWdPrivacyIBin pct16_23 comb16_23 RefusalWithdrawalBin
RefWdMuchTimeBin pct17_23 comb17_23 RefusalWithdrawalBin
RefWdOnlineBin pct18_23 comb18_23 RefusalWithdrawalBin
RefWdDislikeOnlineBin pct19_23 comb19_23 RefusalWithdrawalBin
RefWdCOVIDBin pct20_23 comb20_23 RefusalWithdrawalBin 
RefWdUnableBin pct21_23 comb21_23 RefusalWithdrawalBin
RefWdIncarceratedBin pct22_23 comb22_23 RefusalWithdrawalBin
RefWdOthRsnBin pct23_23 comb23_23 RefusalWithdrawalBin
RefWdPaymentBin pct24_23 comb24_23 RefusalWithdrawalBin2;
define sitechar / id group center flow;
define RefWdNotGivenBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyJBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center noprint;
define RefWdNoInterestBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'No longer interested in study' style(column)=[cellwidth=1in] center noprint;
define RefWdSickBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Too sick' style(column)=[cellwidth=1in] center noprint;
define RefWdInternetBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'No reliable access to internet' style(column)=[cellwidth=1in] center noprint;
define RefWdWorriedResBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Worried about results' style(column)=[cellwidth=1in] center noprint;
define RefWdWorriedBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Worried study might find something concerning about me' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Concerned about privacy' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyBBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center;
define RefWdPrivacyCBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center;
define RefWdPrivacyDBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center;
define RefWdPrivacyEBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Worried information is not secure' style(column)=[cellwidth=1in] center;
define RefWdPrivacyFBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center;
define RefWdPrivacyGBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center;
define RefWdPrivacyHBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Worried that information could be used to discriminate' style(column)=[cellwidth=1in] center;
define RefWdPrivacyIBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center;
define RefWdMuchTimeBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Too busy/Takes too much time' style(column)=[cellwidth=1in] center noprint;
define RefWdOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center noprint;
define RefWdDislikeOnlineBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center noprint;
define RefWdCOVIDBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center noprint;
define RefWdUnableBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Participant is now unable to participate' style(column)=[cellwidth=1in] center noprint;
define RefWdIncarceratedBin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Participant is incarcerated' style(column)=[cellwidth=1in] center noprint;
define RefWdOthRsnBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Other reasons' style(column)=[cellwidth=1in] center noprint;
define RefWdPaymentBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Payment is not great enough' style(column)=[cellwidth=1in] center noprint;
define RefusalWithdrawalBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define RefusalWithdrawalBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
/*WHERE RcrtSI_RecruitType_v1r0 NE 180583933;*/
 
compute pct1_23;
pct1_23=RefWdNotGivenBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=RefWdPrivacyJBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=RefWdNoInterestBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=RefWdSickBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=RefWdInternetBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=RefWdWorriedResBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=RefWdWorriedBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=RefWdPrivacyBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=RefWdPrivacyBBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=RefWdPrivacyCBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=RefWdPrivacyDBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=RefWdPrivacyEBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=RefWdPrivacyFBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=RefWdPrivacyGBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=RefWdPrivacyHBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=RefWdPrivacyIBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=RefWdMuchTimeBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=RefWdOnlineBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=RefWdDislikeOnlineBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=RefWdCOVIDBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=RefWdUnableBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=RefWdIncarceratedBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=RefWdOthRsnBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=RefWdPaymentBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

rbreak after / summarize;

/*compute before _page_;
line @1 "(Continued)";
endcomp;*/

compute after;
sitechar="Total";
endcomp;

run;

*Part 3;
Title Reasons for Refusal/Withdrawal Continued; 
proc report data=concept_ids split = '|' spacing = 0;
column sitechar
RefusalWithdrawalBin RefWdNotGivenBin pct1_23 comb1_23 RefusalWithdrawalBin
RefWdPrivacyJBin pct2_23 comb2_23 RefusalWithdrawalBin
RefWdNoInterestBin pct3_23 comb3_23 RefusalWithdrawalBin
RefWdSickBin pct4_23 comb4_23 RefusalWithdrawalBin
RefWdInternetBin pct5_23 comb5_23 RefusalWithdrawalBin
RefWdWorriedResBin pct6_23 comb6_23 RefusalWithdrawalBin
RefWdWorriedBin pct7_23 comb7_23 RefusalWithdrawalBin
RefWdPrivacyBin pct8_23 comb8_23 RefusalWithdrawalBin
RefWdPrivacyBBin pct9_23 comb9_23 RefusalWithdrawalBin
RefWdPrivacyCBin pct10_23 comb10_23 RefusalWithdrawalBin
RefWdPrivacyDBin pct11_23 comb11_23 RefusalWithdrawalBin
RefWdPrivacyEBin pct12_23 comb12_23 RefusalWithdrawalBin
RefWdPrivacyFBin pct13_23 comb13_23 RefusalWithdrawalBin
RefWdPrivacyGBin pct14_23 comb14_23 RefusalWithdrawalBin
RefWdPrivacyHBin pct15_23 comb15_23 RefusalWithdrawalBin
RefWdPrivacyIBin pct16_23 comb16_23 RefusalWithdrawalBin
RefWdMuchTimeBin pct17_23 comb17_23 RefusalWithdrawalBin
RefWdOnlineBin pct18_23 comb18_23 RefusalWithdrawalBin
RefWdDislikeOnlineBin pct19_23 comb19_23 RefusalWithdrawalBin
RefWdCOVIDBin pct20_23 comb20_23 RefusalWithdrawalBin 
RefWdUnableBin pct21_23 comb21_23 RefusalWithdrawalBin
RefWdIncarceratedBin pct22_23 comb22_23 RefusalWithdrawalBin
RefWdOthRsnBin pct23_23 comb23_23 RefusalWithdrawalBin
RefWdPaymentBin pct24_23 comb24_23 RefusalWithdrawalBin2;
define sitechar / id group center flow;
define RefWdNotGivenBin /sum center noprint;
define pct1_23 / computed format=percent8.1 noprint center;
define comb1_23 / computed format=$20. 'Reason not given' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyJBin /sum center noprint;
define pct2_23 / computed format=percent8.1 noprint center;
define comb2_23 / computed format=$20. 'Other privacy concerns' style(column)=[cellwidth=1in] center noprint;
define RefWdNoInterestBin /sum center noprint;
define pct3_23 / computed format=percent8.1 noprint center;
define comb3_23 / computed format=$20. 'No longer interested in study' style(column)=[cellwidth=1in] center noprint;
define RefWdSickBin /sum center noprint;
define pct4_23 / computed format=percent8.1 noprint center;
define comb4_23 / computed format=$20. 'Too sick' style(column)=[cellwidth=1in] center noprint;
define RefWdInternetBin /sum center noprint;
define pct5_23 / computed format=percent8.1 noprint center;
define comb5_23 / computed format=$20. 'No reliable access to internet' style(column)=[cellwidth=1in] center noprint;
define RefWdWorriedResBin /sum center noprint;
define pct6_23 / computed format=percent8.1 noprint center;
define comb6_23 / computed format=$20. 'Worried about results' style(column)=[cellwidth=1in] center noprint;
define RefWdWorriedBin /sum center noprint;
define pct7_23 / computed format=percent8.1 noprint center;
define comb7_23 / computed format=$20. 'Worried study might find something concerning about me' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyBin /sum center noprint;
define pct8_23 / computed format=percent8.1 noprint center;
define comb8_23 / computed format=$20. 'Concerned about privacy' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyBBin /sum center noprint;
define pct9_23 / computed format=percent8.1 noprint center;
define comb9_23 / computed format=$20. 'Does not trust the government' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyCBin /sum center noprint;
define pct10_23 / computed format=percent8.1 noprint center;
define comb10_23 / computed format=$20. 'Does not trust research/researchers' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyDBin /sum center noprint;
define pct11_23 / computed format=percent8.1 noprint center;
define comb11_23 / computed format=$20. 'Does not want information shared with other researchers' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyEBin /sum center noprint;
define pct12_23 / computed format=percent8.1 noprint center;
define comb12_23 / computed format=$20. 'Worried information is not secure' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyFBin /sum center noprint;
define pct13_23 / computed format=percent8.1 noprint center;
define comb13_23 / computed format=$20. 'Worried about data being given to insurance company' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyGBin /sum center noprint;
define pct14_23 / computed format=percent8.1 noprint center;
define comb14_23 / computed format=$20. 'Worried about data being given to employer' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyHBin /sum center noprint;
define pct15_23 / computed format=percent8.1 noprint center;
define comb15_23 / computed format=$20. 'Worried that information could be used to discriminate' style(column)=[cellwidth=1in] center noprint;
define RefWdPrivacyIBin /sum center noprint;
define pct16_23 / computed format=percent8.1 noprint center;
define comb16_23 / computed format=$20. 'Worried that information will be used by others to make a profit' style(column)=[cellwidth=1in] center noprint;
define RefWdMuchTimeBin /sum center noprint;
define pct17_23 / computed format=percent8.1 noprint center;
define comb17_23 / computed format=$20. 'Too busy/Takes too much time' style(column)=[cellwidth=1in] center;
define RefWdOnlineBin /sum center noprint;
define pct18_23 / computed format=percent8.1 noprint center;
define comb18_23 / computed format=$20. 'Not able to complete study activities online' style(column)=[cellwidth=1in] center;
define RefWdDislikeOnlineBin /sum center noprint;
define pct19_23 / computed format=percent8.1 noprint center;
define comb19_23 / computed format=$20. 'Does not like to do things online' style(column)=[cellwidth=1in] center;
define RefWdCOVIDBin /sum center noprint;
define pct20_23 / computed format=percent8.1 noprint center;
define comb20_23 / computed format=$20. 'Concerned about COVID-19' style(column)=[cellwidth=1in] center;
define RefWdUnableBin /sum center noprint;
define pct21_23 / computed format=percent8.1 noprint center;
define comb21_23 / computed format=$20. 'Participant is now unable to participate' style(column)=[cellwidth=1in] center;
define RefWdIncarceratedBin /sum center noprint;
define pct22_23 / computed format=percent8.1 noprint center;
define comb22_23 / computed format=$20. 'Participant is incarcerated' style(column)=[cellwidth=1in] center;
define RefWdOthRsnBin /sum center noprint;
define pct23_23 / computed format=percent8.1 noprint center;
define comb23_23 / computed format=$20. 'Other reasons' style(column)=[cellwidth=1in] center;
define RefWdPaymentBin /sum center noprint;
define pct24_23 / computed format=percent8.1 noprint center;
define comb24_23 / computed format=$20. 'Payment is not great enough' style(column)=[cellwidth=1in] center;
define RefusalWithdrawalBin / sum noprint 'Total Opt-Outs' style(column)=[cellwidth=1in] center;
define RefusalWithdrawalBin2 / 'Total Opt-Outs' style(column)=[cellwidth=1.5in] center;
/*WHERE RcrtSI_RecruitType_v1r0 NE 180583933;*/
 
compute pct1_23;
pct1_23=RefWdNotGivenBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb1_23 / char;
comb1_23=catt(strip(put(_c3_,8.)),' (',strip(put(_c4_,percent8.1)),')');
endcomp;

compute pct2_23;
pct2_23=RefWdPrivacyJBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb2_23 / char;
comb2_23=catt(strip(put(_c7_,8.)),' (',strip(put(_c8_,percent8.1)),')');
endcomp;

compute pct3_23;
pct3_23=RefWdNoInterestBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb3_23 / char;
comb3_23=catt(strip(put(_c11_,8.)),' (',strip(put(_c12_,percent8.1)),')');
endcomp;

compute pct4_23;
pct4_23=RefWdSickBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb4_23 / char;
comb4_23=catt(strip(put(_c15_,8.)),' (',strip(put(_c16_,percent8.1)),')');
endcomp;

compute pct5_23;
pct5_23=RefWdInternetBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb5_23 / char;
comb5_23=catt(strip(put(_c19_,8.)),' (',strip(put(_c20_,percent8.1)),')');
endcomp;

compute pct6_23;
pct6_23=RefWdWorriedResBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb6_23 / char;
comb6_23=catt(strip(put(_c23_,8.)),' (',strip(put(_c24_,percent8.1)),')');
endcomp;

compute pct7_23;
pct7_23=RefWdWorriedBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb7_23 / char;
comb7_23=catt(strip(put(_c27_,8.)),' (',strip(put(_c28_,percent8.1)),')');
endcomp;

compute pct8_23;
pct8_23=RefWdPrivacyBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb8_23 / char;
comb8_23=catt(strip(put(_c31_,8.)),' (',strip(put(_c32_,percent8.1)),')');
endcomp;

compute pct9_23;
pct9_23=RefWdPrivacyBBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb9_23 / char;
comb9_23=catt(strip(put(_c35_,8.)),' (',strip(put(_c36_,percent8.1)),')');
endcomp;

compute pct10_23;
pct10_23=RefWdPrivacyCBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb10_23 / char;
comb10_23=catt(strip(put(_c39_,8.)),' (',strip(put(_c40_,percent8.1)),')');
endcomp;

compute pct11_23;
pct11_23=RefWdPrivacyDBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb11_23 / char;
comb11_23=catt(strip(put(_c43_,8.)),' (',strip(put(_c44_,percent8.1)),')');
endcomp;

compute pct12_23;
pct12_23=RefWdPrivacyEBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb12_23 / char;
comb12_23=catt(strip(put(_c47_,8.)),' (',strip(put(_c48_,percent8.1)),')');
endcomp;

compute pct13_23;
pct13_23=RefWdPrivacyFBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb13_23 / char;
comb13_23=catt(strip(put(_c51_,8.)),' (',strip(put(_c52_,percent8.1)),')');
endcomp;

compute pct14_23;
pct14_23=RefWdPrivacyGBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb14_23 / char;
comb14_23=catt(strip(put(_c55_,8.)),' (',strip(put(_c56_,percent8.1)),')');
endcomp;

compute pct15_23;
pct15_23=RefWdPrivacyHBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb15_23 / char;
comb15_23=catt(strip(put(_c59_,8.)),' (',strip(put(_c60_,percent8.1)),')');
endcomp;

compute pct16_23;
pct16_23=RefWdPrivacyIBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb16_23 / char;
comb16_23=catt(strip(put(_c63_,8.)),' (',strip(put(_c64_,percent8.1)),')');
endcomp;

compute pct17_23;
pct17_23=RefWdMuchTimeBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb17_23 / char;
comb17_23=catt(strip(put(_c67_,8.)),' (',strip(put(_c68_,percent8.1)),')');
endcomp;

compute pct18_23;
pct18_23=RefWdOnlineBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb18_23 / char;
comb18_23=catt(strip(put(_c71_,8.)),' (',strip(put(_c72_,percent8.1)),')');
endcomp;

compute pct19_23;
pct19_23=RefWdDislikeOnlineBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb19_23 / char;
comb19_23=catt(strip(put(_c75_,8.)),' (',strip(put(_c76_,percent8.1)),')');
endcomp;

compute pct20_23;
pct20_23=RefWdCOVIDBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb20_23 / char;
comb20_23=catt(strip(put(_c79_,8.)),' (',strip(put(_c80_,percent8.1)),')');
endcomp;

compute pct21_23;
pct21_23=RefWdUnableBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb21_23 / char;
comb21_23=catt(strip(put(_c83_,8.)),' (',strip(put(_c84_,percent8.1)),')');
endcomp;

compute pct22_23;
pct22_23=RefWdIncarceratedBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb22_23 / char;
comb22_23=catt(strip(put(_c87_,8.)),' (',strip(put(_c88_,percent8.1)),')');
endcomp;

compute pct23_23;
pct23_23=RefWdOthRsnBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb23_23 / char;
comb23_23=catt(strip(put(_c91_,8.)),' (',strip(put(_c92_,percent8.1)),')');
endcomp;

compute pct24_23;
pct24_23=RefWdPaymentBin.sum/RefusalWithdrawalBin.sum;
endcomp;
 
compute comb24_23 / char;
comb24_23=catt(strip(put(_c95_,8.)),' (',strip(put(_c96_,percent8.1)),')');
endcomp;

rbreak after / summarize;

/*compute before _page_;
line @1 "(Continued)";
endcomp;*/

compute after;
sitechar="Total";
endcomp;

run;
