/*** HELP START ***//*

Program:     rich_kaplan_meier_plot.txt  
 Macro:       %rich_kaplan_meier_plot  
   
 Purpose:     This macro generates a rich Kaplan-Meier survival plot using PROC LIFETEST in SAS.  
              It produces survival curves by group, displays censoring marks, event marks,  
              number-at-risk bands, and number-at-risk tables in a split-panel layout.  
  
 Interpretation Note:  
   - The number-at-risk band is not a probability density, frequency distribution,  
     or Raincloud-style density display.  
   - The number-at-risk band represents the risk set within each group, standardized  
     from the group-specific minimum and maximum number at risk to a 0-1 scale.  
   - The band is shown at time points where the risk set changes due to an event  
     or censoring, and is intended only as a visual summary of the changing risk set.  
 
 Parameters:  
   data=                  Input dataset name (default: dummy_adtte)  
   wh=                    WHERE condition to subset data (optional)  
   groupn=                Numeric group variable used for stratification (e.g., TRTPN)  
   groupc=                Character group label variable (e.g., TRTP)  
   idvar=                 Subject identifier variable used for tooltips (e.g., USUBJID)  
   Time_var=              Time-to-event variable (e.g., AVAL)  
   Censor_var=            Censoring indicator variable (e.g., CNSR)  
   Censor_val=            Value indicating censored observations (e.g., 1)  
   Title=                 Plot title (default: "Kaplan-Meier Plot")  
   XLABEL=                Label for the X-axis (e.g., "Survival Time (Month)")  
   YLABEL=                Label for the Y-axis (e.g., "Probability of Survival")  
   AxisValues=            Tick marks for the X-axis (e.g., "0 1 2 3 4 5")  
   Generate_Code=         Option to output MFILE-generated SAS code (Y/N)  
   
 Notes:  
   - This macro is designed for a maximum of 4 strata.  
   - The numeric group variable should use values 1 to 4 for proper label assignment.  
   - The HTML output file is generated in the WORK directory as `RichKM.html`.  
   - When Generate_Code=Y, the MPRINT-generated SAS code is exported to the WORK directory.  
   
 Example usage:  
   %rich_kaplan_meier_plot(  
       data = dummy_adtte,  
       wh = %nrbquote(TRTPN in (1: 2)),  
       groupn = TRTPN,  
       groupc = TRTP,  
       idvar = USUBJID,  
       Time_var = AVAL,  
       Censor_var = CNSR,  
       Censor_val = 1,  
       Title = %nrbquote(Rich Kaplan-Meier Plot),  
       XLABEL = %nrbquote(Survival Time (Month)),  
       YLABEL = %nrbquote(Probability of Survival),  
       AxisValues = %nrbquote(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15),  
       Generate_Code = Y  
   );  

 Author:     Yutaka Morioka  
 First Release Date:        2026-07-06  
 Update:     2026-07-06 (Initial version)

*//*** HELP END ***/

%macro rich_kaplan_meier_plot(
data = dummy_adtte ,
wh=,
groupn = TRTPN ,
groupc = TRTP ,
idvar = USUBJID,
Time_var = AVAL ,
Censor_var = CNSR ,
Censor_val = 1 ,
Title = %nrbquote(Kaplan-Meier Plot),
XLABEL =%nrbquote( Survival Time (Month)),
YLABEL =%nrbquote( Probability of Survival),
AxisValues =%nrbquote (0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15),
Generate_Code =Y
);

%let codepath = %sysfunc(pathname(WORK));
%put &codepath;
options nomfile;
%if %upcase(&Generate_Code) =Y %then %do;
%let sysind =&sysindex;
filename mprint "&codepath./rich_kaplan_meier_plot&sysind..txt";
options mfile mprint;
%end;
data dummy_adtte;
attrib
USUBJID label="Unique Subject Identifier" length=$20.
TRTP  label="Planned Treatment" length=$20.
TRTPN	label="Planned Treatment (N)" length=8.
PARAM  label="Parameter" length=$50.
PARAMCD label="Parameter Code" length=$20.
PARAMN  label="Parameter (N)" length=8.
AVAL  label="Analysis Value" length=8.
CNSR  label="Censor" length=8.
;
call streaminit(1982);
do TRTPN = 1 to 4;
do _USUBJID = 1 to 100;
do PARAMN = 1 to 1;
if TRTPN =1 then time =rand('WEIBULL', 1.5, 10);
else if TRTPN =2 then time =rand('WEIBULL', 1.5, 7);
else if TRTPN =3 then time =rand('WEIBULL', 1.5, 3);
else time =rand('WEIBULL', 1.5, 5);
USUBJID = cats(TRTPN,_USUBJID);
censor_limit = rand('UNIFORM') * 15;
CNSR = ^(time <= censor_limit);
AVAL = min(time, censor_limit);
TRTP = choosec(TRTPN,"XXXXX","YYYYY","ZZZZZ","Placebo");
PARAMCD = choosec(PARAMN,"PFS");
PARAM = choosec(PARAMN,"Progression Free Survival (Months)");
output;
end;
end;
end;
keep USUBJID -- CNSR;
run;

data _&data;
set &data;
%if %length(&wh) >0 %then %do;
where &wh. ;
%end;
run;

proc sort data=_&data.(keep=&groupn. &groupc.) out=group_fmt nodupkey;
by &groupn. &groupc.;
run;

data group_fmt;
set group_fmt;
FMTNAME = "$RKM_GR";
START = cats(&groupn.);
LABEL = &groupc.;
call symputx(cats("label",&groupn. ),LABEL);
run;
proc format cntlin=group_fmt;
run;

ods graphics on;
ods noresults;
ods select none;
ods output Survivalplot=SurvivalPlotData;
ods output ProductLimitEstimates =ProductLimitEstimates;
proc lifetest data=_&data.
 plots=survival(atrisk=&AxisValues. cl);
 time &Time_var. * &Censor_var.(&Censor_val.);
 strata &groupn. ;
 id &idvar.;
run;
ods results;
ods select all;

proc sql noprint;
select max(StratumNum) into :max_StratumNum
from SurvivalPlotData;
quit;

%if 4 < &max_StratumNum. %then %do;
  %put WARNING: rich_kaplan_meier_plot supports up to 4 strata only.;
%end;

proc sort data=SurvivalPlotData(keep = Stratum) out=Stratum nodupkey;
 by Stratum;
run;
proc sort data=SurvivalPlotData(keep = tAtRisk) out=tAtRisk nodupkey;
 where ^missing(tAtRisk);
 by tAtRisk;
run;
data atrisk;
set Stratum;
if _N_=1 then do;
  declare hash h1(dataset:"SurvivalPlotData(keep=Stratum tAtRisk)");
  h1.definekey("Stratum","tAtRisk");
  h1.definedone();
end;
do i=1 to obs;
  set tAtRisk nobs=obs point=i;
  AtRisk=0;
  if h1.check() ne 0 then output;
end;
run;
data SurvivalPlotData_1;
set SurvivalPlotData atrisk;
if ^missing(Censored) then do;
  tick_marks_upper = Censored + 0.02;
  tick_marks_lower = Censored - 0.02;
end;
run;
proc sort data=SurvivalPlotData_1 out=_SurvivalPlotData_1;
by Stratum;
run;
proc stdize data= _SurvivalPlotData_1
    out = atrisk_volum
    method=range
    add = 0
    mult = 1
;
where ^missing(Stratum);
by Stratum;
var atrisk;
run;

data SurvivalPlotData_2;
set SurvivalPlotData_1( rename=(Stratum=_Stratum)) atrisk_volum(in=ina rename=(atrisk=atrisk_band Stratum=_Stratum));
if ina then do;
 NaR_time=time;
 call missing(of time);
end;
else do;
  call missing(of atrisk_band);
end;
Stratum=cats(_Stratum);
format atrisk_band best.  ;
drop _Stratum;
run;

data Productlimitestimates_1;
set Productlimitestimates(rename=(STRATUM=_STRATUM));
where ^missing(&idvar.);
if Censor = 0 then Event_time=&Time_var.;
if Censor = 1 then Cens_time=&Time_var.;
STRATUM=cats(_STRATUM);
keep STRATUM &idvar. Event_time Cens_time;
run;

data SurvivalPlotData_3;
  length Stratum $200.;
  set SurvivalPlotData_2(in=ina) Productlimitestimates_1(in=inb );
  length TRTNAME  $20.;
  TRTNAME=put(Stratum,$RKM_GR.);
  dumm_y1=0;

   if ina then do;
    %do i = 1 %to &max_StratumNum.;
    if Stratum="&i." then do;
       band&i._upper = atrisk_band;
       band&i._lower = dumm_y1;
       risk&i.       = atrisk;
       label risk&i.="&&label&i.";
    end;
    %end;
  end;

   if inb then do;
     %do i = 1 %to &max_StratumNum.;
       if Stratum="&i." then do;
         censor&i.     = dumm_y1;
          event&i.     = dumm_y1;
      end;
     %end;
  end;

 bar="|";
run;



proc template;

define statgraph KM_PLOT_SPLIT;

dynamic _title;

begingraph / border=false;

entrytitle _title;

discreteattrmap name='trtmap';
%if 1 <= &max_StratumNum. %then %do;
   value "&label1" /
      lineattrs=(color=cx2A25D9 thickness=2)
      markerattrs=(color=cx2A25D9)
      fillattrs=(color=cx2A25D9);
%end;
%if 2 <= &max_StratumNum. %then %do;
   value "&label2" /
      lineattrs=(color=cxB2182B thickness=2)
      markerattrs=(color=cxB2182B)
      fillattrs=(color=cxB2182B);
%end;
%if 3 <= &max_StratumNum. %then %do;
   value "&label3" /
      lineattrs=(color=cx01665E thickness=2)
      markerattrs=(color=cx01665E)
      fillattrs=(color=cx01665E);
%end;
%if 4 <= &max_StratumNum. %then %do;
   value "&label4" /
      lineattrs=(color=cx543005 thickness=2)
      markerattrs=(color=cx543005)
      fillattrs=(color=cx543005);
%end;
enddiscreteattrmap;

discreteattrvar attrvar=Stratum
                var=Stratum
                attrmap='trtmap';
%if 1 <= &max_StratumNum. %then %do;
legendItem type=FILL name="blue1" /
   fillattrs=(color=cx2A25D9 transparency =0.8) filldisplay=(fill) %if &max_StratumNum.=1 %then %do; label="Number at Risk;" %end;;
%end;
%if 2 <= &max_StratumNum. %then %do;
legendItem type=FILL name="red1" /
   fillattrs=(color=cxB2182B transparency =0.8) filldisplay=(fill) %if &max_StratumNum.=2 %then %do; label="Number at Risk;" %end;;
%end;
%if 3 <= &max_StratumNum. %then %do;
legendItem type=FILL name="green1" /
   fillattrs=(color=cx01665E transparency =0.8) filldisplay=(fill) %if &max_StratumNum.=3 %then %do; label="Number at Risk;" %end; ;
%end;
%if 4 <= &max_StratumNum. %then %do;
legendItem type=FILL name="brown1" /
   fillattrs=(color=cx543005 transparency =0.8) filldisplay=(fill) %if &max_StratumNum.=4 %then %do; label="Number at Risk;" %end;;
%end;

%if 1 <= &max_StratumNum. %then %do;
legendItem type=text name="blue2" /
   text="|" textattrs=(color=cx2A25D9 ) %if &max_StratumNum.=1 %then %do; label="Event;" %end;;
%end;
%if 2 <= &max_StratumNum. %then %do;
legendItem type=text name="red2" /
   text="|" textattrs=(color=cxB2182B ) %if &max_StratumNum.=2 %then %do; label="Event;" %end;;
%end;
%if 3 <= &max_StratumNum. %then %do;
legendItem type=text name="green2" /
   text="|" textattrs=(color=cx01665E ) %if &max_StratumNum.=3 %then %do; label="Event;" %end;;
%end;
%if 4 <= &max_StratumNum. %then %do;
legendItem type=text name="brown2" /
   text="|" textattrs=(color=cx543005 ) %if &max_StratumNum.=4 %then %do; label="Event;" %end;;
%end;

legendItem type=text name="gray" /
   text="|" textattrs=(color=gray )  label="Censor";

layout lattice / outerpad=(top=0px bottom=0px)  pad=(top=0px bottom=0px left=0px right=0px)
   rows=%eval(1+ 2*&max_StratumNum.)

   %if &max_StratumNum = 1 %then %do;
   rowweights=(0.72 0.18 0.1 )
   %end;
   %if &max_StratumNum = 2 %then %do;
   rowweights=(0.72 0.09 0.05 0.09 0.05)
   %end;
   %if &max_StratumNum = 3 %then %do;
   rowweights=(0.64 0.08 0.04 0.08 0.04 0.08 0.04)
   %end;
   %if &max_StratumNum = 4 %then %do;
   rowweights=(0.6 0.06 0.04 0.06 0.04 0.06 0.04 0.06 0.04)
   %end;

   rowgutter=0.01;

   /****************************************/
   /* Row1 : KM Curve                      */
   /****************************************/

   layout overlay /
      walldisplay=none

      xaxisopts=(
         label="&XLABEL."
         linearopts=(
            tickvaluelist=(&AxisValues)
         )
      )

      yaxisopts=(
         label="&YLABEL."
         linearopts=(
            viewmin=0
            viewmax=1.05
            tickvaluelist=(0 .2 .4 .5 .6 .8 1.0)
         )
      );

      stepplot
         x=time
         y=survival
         /
         group=Stratum
         lineattrs=(thickness=2)
         name='step';

      scatterplot
         x=time
         y=censored/
         group=Stratum
         yerrorupper=tick_marks_upper
         yerrorlower=tick_marks_lower
         markerattrs=(size=0)
         errorbarattrs=(thickness=2)
         errorbarcapshape=none;

      discretelegend 'step' /
         location=inside
         halign=right
         valign=top
         border=false;
   discretelegend 
   "blue1"
%if 2 <= &max_StratumNum. %then %do;
   "red1" 
%end;
%if 3 <= &max_StratumNum. %then %do;
   "green1" 
%end;
%if 4 <= &max_StratumNum. %then %do;
   "brown1" 
%end;
   "blue2"
%if 2 <= &max_StratumNum. %then %do;
   "red2" 
%end;
%if 3 <= &max_StratumNum. %then %do;
   "green2" 
%end;
%if 4 <= &max_StratumNum. %then %do;
   "brown2" 
%end;


"gray"/location=outside halign=right valign=bottom  border=false;


   endlayout;

%do i = 1 %to &max_StratumNum.;
   %if &i = 1 %then %do;  %let color = cx2A25D9;  %end;
   %if &i = 2 %then %do;  %let color = cxB2182B;  %end;
   %if &i = 3 %then %do;  %let color = cx01665E;  %end;
   %if &i = 4 %then %do;  %let color = cx543005;  %end;

   /****************************************/
   /* Row : At Risk Band                    */
   /****************************************/
   layout overlay /outerpad=(top=0px bottom=0px)
      walldisplay=none

      xaxisopts=(display=none)

      yaxisopts=(
         display=none
         linearopts=(viewmin=-0.15 viewmax=1)
         offsetmax=0
         offsetmin=0
      );

      bandplot
         x=NaR_time
         limitupper=band&i._upper
         limitlower=band&i._lower /
         fillattrs=(color=&color.)
         datatransparency=0.8
;

      scatterplot
         x=Cens_time
         y=censor&i. /
         markercharacter=bar
         markercharacterposition=bottom
         markercharacterattrs=(
            color=gray
            size=3
         )
         rolename=(tip1=&idvar. tip2=Cens_time) 
         tip=(tip1 tip2)
         tiplabel=(tip1="&idvar." tip2="Censor Time")
;
      scatterplot
         x=Event_time
         y=event&i. /
         markercharacter=bar
         markercharacterposition=top
         markercharacterattrs=(
            color=&color.
            size=3
         )
         rolename=(tip1=&idvar. tip2=Event_time) 
         tip=(tip1 tip2)
         tiplabel=(tip1="&idvar." tip2="Event Time")
;

   endlayout;


   /****************************************/
   /* Row : At Risk Table                 */
   /****************************************/
   layout overlay / pad=(top=0px bottom=0px left=0px right=0px) outerpad=(top=0px bottom=5px)
      walldisplay=none

      xaxisopts=(display=none)
      yaxisopts=(display=none);

      axistable
         x=tAtRisk
         value=risk&i. /
         %if &max_StratumNum. <= 3 %then %do;
         valueattrs=(size=8);
         %end;
         %else %do;
         valueattrs=(size=6);
         %end;
   endlayout;
%end;


endlayout;

endgraph;
end;
run;

ods select all;
ods graphics on/imagemap=on TIPMAX=1000;
ods html path="&codepath." file="RichKM.html" 
;
title "&Title";
proc sgrender data=SurvivalPlotData_3 template=KM_PLOT_SPLIT;
  dynamic _title="";
  format Stratum $RKM_GR.;
run;
ods html close;
%put NOTE: Generated Plot HTML File:  &codepath./kaplan_meier_plot&sysind..txt;

%if %upcase(&Generate_Code) =Y %then %do;
  %*-- Only for Windows system --*;
  %if %index(%upcase(&SYSSCP), WIN) > 0 %then %do;
    options noxwait noxsync;
  %end;
  options nomprint nomfile;
  filename mprint clear;
  data _null_;
    put "NOTE: Generated Program Code File: &codepath./rich_kaplan_meier_plot&sysind..txt";
  	call sleep(1,1);
  run;

  %*-- Open file when use XCMD --*;
  %if %sysfunc(getoption(xcmd))=XCMD %then %do;
    %sysexec "&codepath./rich_kaplan_meier_plot&sysind..txt";
  %end;
%end;

  %if %sysfunc(getoption(xcmd))=XCMD %then %do;
    %sysexec "&codepath./RichKM.html";
  %end;


%mend;

