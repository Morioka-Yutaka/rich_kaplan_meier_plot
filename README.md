# rich_kaplan_meier_plot
This package provides a Rich Kaplan-Meier plot for SAS, enhancing standard survival curves with censoring marks, event marks, standardized number-at-risk bands, and risk tables. It helps visualize survival probability and risk-set dynamics across up to four groups in an intuitive, presentation-ready format.

<img width="206" height="206" alt="rich_kaplan_meier_plot" src="https://github.com/user-attachments/assets/149087ce-7c94-44be-953a-538798487ffe" />   

【Rich Kaplan-meier Plot】   
<img width="503" height="393" alt="image" src="https://github.com/user-attachments/assets/484ffba6-a65c-4021-a6e9-bc4fc07692c2" />  

The Rich Kaplan-Meier Plot is an enhanced survival plot designed to make Kaplan-Meier analysis more informative and visually intuitive. In addition to the standard survival curves, it displays censoring marks, event marks, number-at-risk tables, and standardized number-at-risk bands for each group.  
The main benefit of this plot is that it allows users to understand not only the estimated survival probability over time, but also how the underlying risk set changes throughout follow-up.   In a standard Kaplan-Meier plot, the number at risk is usually shown only as a table below the graph. In the Rich Kaplan-Meier Plot, the number-at-risk band provides a visual summary of the changing risk set along the same time axis as the survival curve.  
The survival curve should be interpreted in the usual Kaplan-Meier manner: each downward step represents an event, while censoring marks indicate subjects whose follow-up ended without an event. The lower panels show event and censoring times for each group.   The number-at-risk band represents the within-group risk set standardized from its group-specific minimum and maximum to a 0-1 scale. It is not a probability density, frequency distribution, or Raincloud-style density display.  
This plot is useful when comparing survival patterns across treatment groups, especially when the reliability of late survival estimates depends on how many subjects remain at risk.   By combining survival estimates, event timing, censoring information, and risk-set dynamics, the Rich Kaplan-Meier Plot provides a clearer and more comprehensive view of time-to-event data.


