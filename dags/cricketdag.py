from datetime import datetime, timedelta
from airflow.sdk import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.standard.operators.bash import BashOperator

RAW_TABLE = "CAPSTONE_DB.RAW.RAW_CRICKET"
DAG_ID = "cricket_pipeline"
CONN_ID = "snowflake_default"
STAGE = "CAPSTONE_DB.RAW.RAW_STAGE"
FILE_FORMAT = "CAPSTONE_DB.RAW.CSV_FF"
DATA_DIR = "/usr/local/airflow/include/data"
DBT = "/usr/local/airflow/dbt_venv/bin/dbt"
DBT_DIR = "/usr/local/airflow/dbt/capstone"
DBT_CMD = f"cd {DBT_DIR} && {DBT}"
default_args={"owner":"jigar","retries":2,"retry_delay":timedelta(minutes=1) }
with DAG(
    dag_id=DAG_ID,
    start_date=datetime(2026,10,10),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,
    default_args=default_args
) as dag:
    upload_file=SQLExecuteQueryOperator(
        task_id="loading_to_stage",
        conn_id=CONN_ID,
        sql=f"PUT file://{DATA_DIR}/*.csv @{STAGE} AUTO_COMPRESS = TRUE OVERWRITE = TRUE",

    )
    copy_into_raw=SQLExecuteQueryOperator(
        task_id="copy_to_raw",
        conn_id=CONN_ID,
        sql=f"""copy into {RAW_TABLE} from @{STAGE}
                file_format=(format_name='{FILE_FORMAT}')
                pattern='.*\\.csv.*'
                match_by_column_name = case_insensitive
                include_metadata = (
                    _source_file = metadata$filename,
                    _loaded_at  = metadata$start_scan_time)
                on_error = 'abort_statement'""",
    )
    dbt_silver = BashOperator(
        task_id="silver_layer",
        bash_command=f"{DBT_CMD} build --profiles-dir . --select silver",
    )

upload_file>>copy_into_raw>>dbt_silver