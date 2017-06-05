import quandl
import numpy as np
import pandas as pd
quandl.ApiConfig.api_key = "bM1sEKXKyLhXPJzBzkm4"

_exchange_list = "CME"
_10_year_treasury_note_futures = "TY"
_emini_sp_futures = "ES"


class FuturesData:
    _month_contract = ["H", "M", "U", "Z"]

    def __init__(self,
                 contract, exchange=None,
                 start_year=1990, end_year=2017):

        if exchange is None:
            exchange = "CME"
        self.exchange = exchange
        self.contract = contract
        self.start_year = start_year
        self.end_year = end_year

    def get_data(self):
        agg_df = pd.DataFrame()
        years = np.arange(self.start_year, self.end_year)
        for y in years:
            quandl_quote = "CME/ESU" + str(y)
            data = quandl.get(quandl_quote)
            agg_df = agg_df.append(data)
        self.agg_df = agg_df
