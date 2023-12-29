"""
This is the code to combine student attendance exported from Moodle Learning Management System.
In Moodle it was possible to only export the attendance only for individual modules, while one
might need to look at the overall attendance status of a student. This code helped to place all
exported attendances of a level in a folder and then combine them all in excel file to look
at every student's overall attendance.
"""

from pathlib import Path
import os
import glob
import pandas as pd

# getting files to be merged from the path  
main_folder = Path(r"C:\Users\path")

# read all the files in the main folder
print(type(main_folder))
subfolders=os.listdir(main_folder)

# data frame for the new output
writer = pd.ExcelWriter(r"C:\Users\path")

for i in range(len(subfolders)):
    final_df = pd.DataFrame()
    for excel_file in glob.glob(os.path.join(main_folder,subfolders[i],"*.xlsx")):
        fileName = os.path.basename(excel_file)
        subjectName = fileName.split('.')[0]
        
        df = pd.read_excel(excel_file)
        df['Full name']=df['First name']+" "+df['Surname']
        
        if final_df.empty==True:
            final_df['Full name']=df['Full name']
            final_df[subjectName]= df['Percentage']

        else:
            final_df[subjectName]=df['Percentage']
    #print(final_df)
    
    final_df.to_excel(writer,sheet_name=subfolders[i],index=False)
 
writer.close()
