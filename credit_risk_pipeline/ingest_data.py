import os

import pandas as pd

from sqlalchemy import create_engine



CSV_FILE_PATH = r"D:\Nikhil_Files\Downloads\SQL_Projects_practice\Finance_loan_risk_Prediction\loan_risk_prediction_dataset.csv"
SERVER_NAME = r"NIKSIDEAPAD\SQLEXPRESS"

DATABASE_NAME = "creditrisk_db"



# Connection string leveraging local Windows Trusted Authentication

connection_url = (

    f"mssql+pyodbc://@{SERVER_NAME}/{DATABASE_NAME}"

    f"?driver=ODBC+Driver+17+for+SQL+Server"

    f"&trusted_connection=yes"

    f"&TrustServerCertificate=yes"

)



def main():

    if not os.path.exists(CSV_FILE_PATH):

        print(f"❌ Cannot locate source data file: {CSV_FILE_PATH}")

        return



    print("📖 Reading loan application data streams...")

    df = pd.read_csv(CSV_FILE_PATH)

    

    print("🔗 Initializing database communication channel...")

    engine = create_engine(connection_url)

    

    print("📥 Committing data records to table: loans_raw...")

    df.to_sql(name="loans_raw", con=engine, if_exists="replace", index=False)

    print("🎉 Phase 1 Complete! Raw injection layer verified.")



if __name__ == "__main__":
    main()