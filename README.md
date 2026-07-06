# rich_kaplan_meier_plot
This package provides a Rich Kaplan-Meier plot for SAS, enhancing standard survival curves with censoring marks, event marks, standardized number-at-risk bands, and risk tables. It helps visualize survival probability and risk-set dynamics across up to four groups in an intuitive, presentation-ready format.

<img width="206" height="206" alt="rich_kaplan_meier_plot" src="https://github.com/user-attachments/assets/149087ce-7c94-44be-953a-538798487ffe" />   

【Rich Kaplan-meier Plot】   
<img width="503" height="393" alt="image" src="https://github.com/user-attachments/assets/484ffba6-a65c-4021-a6e9-bc4fc07692c2" />  

The Rich Kaplan-Meier Plot is an enhanced survival plot designed to make Kaplan-Meier analysis more informative and visually intuitive. In addition to the standard survival curves, it displays censoring marks, event marks, number-at-risk tables, and standardized number-at-risk bands for each group.  
The main benefit of this plot is that it allows users to understand not only the estimated survival probability over time, but also how the underlying risk set changes throughout follow-up.   In a standard Kaplan-Meier plot, the number at risk is usually shown only as a table below the graph. In the Rich Kaplan-Meier Plot, the number-at-risk band provides a visual summary of the changing risk set along the same time axis as the survival curve.  
The survival curve should be interpreted in the usual Kaplan-Meier manner: each downward step represents an event, while censoring marks indicate subjects whose follow-up ended without an event. The lower panels show event and censoring times for each group.   The number-at-risk band represents the within-group risk set standardized from its group-specific minimum and maximum to a 0-1 scale. It is not a probability density, frequency distribution, or Raincloud-style density display.  
This plot is useful when comparing survival patterns across treatment groups, especially when the reliability of late survival estimates depends on how many subjects remain at risk.   By combining survival estimates, event timing, censoring information, and risk-set dynamics, the Rich Kaplan-Meier Plot provides a clearer and more comprehensive view of time-to-event data.


---
 
## `%rich_kaplan_meier_plot()` macro <a name="richkaplanmeierplot-macro-1"></a> ######

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
  
---
