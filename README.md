# ConnectMetricsAndReports

For CCC Daily Report, CCC Weekly Report, Refusals/Withdrawals, and Biospecimen Outreach Reports:
Download the recruitment data and save it in the format "recruitment_environment_date", so for example recruitment_prod_052522. Import it into SAS Enterprise Guide (change all $Char24 to DATETIME format from the drop down menu) and create a new copy of the code (SAS EG will prompt you to do this in order to make edits to the code). Copy and paste the all of the code from the "Data Processing" SAS program (in the "SAS Code for Metrics" file) from where it says "Labeling Concept IDs" and below. In the import code, make sure to change the file name in the code to match the name of the file that is being imported (this will likely just be a date change if you keep the same naming convention for the data file). This will be at the end of the "Labeling Concept IDs" section where it says From ____ and you will update the file name here. Make sure to save the summary stat macro to your local file, and change all file locations in the import code, daily metrics code, and weekly report code to your local file path. Run the Data Processing code first, and then you can run the codes for the CCC Daily Report, CCC Weekly Report, and the other reports in the "SAS Code for Metrics" file. 

For Incentives Report:
In BQ, type in the query: 
SELECT token, d_130371375.d_266600170.d_731498909, d_130371375.d_266600170.d_222373868, d_130371375.d_266600170.d_787567527 FROM `nih-nci-dceg-connect-prod-6d04.Connect.participants` 
WHERE d_130371375.d_266600170.d_731498909 = 353358909
Save the file as a csv in your local drive, and upload it into SAS Enterprise Guide in the same way as for the recruitment data (above). This report does not use a separate macro file (unlike for the recruitment data above). Make sure to change all file paths to your own file path. 

For Duplicate Report:
In BQ, type in the query: 
SELECT token, Connect_ID, d_827220437, d_512820379, d_821247024, d_914594314, state.d_148197146 FROM `nih-nci-dceg-connect-prod-6d04.Connect.participants`
WHERE state.d_148197146 is not null
Save the file as a csv in your local drive, and upload it into SAS Enterprise Guide in the same way as for the recruitment data (above). This report does not use a separate macro file (unlike for the recruitment data above). Make sure to change all file paths to your own file path. 

For the BSI Pie Charts:
Run the R code as is
