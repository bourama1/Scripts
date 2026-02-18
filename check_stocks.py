import time
from datetime import datetime

import pandas as pd
import requests


def get_stock_data(ticker):
    """Direct Yahoo Finance API - no yfinance needed"""
    try:
        url = f"https://query1.finance.yahoo.com/v10/finance/quoteSummary/{ticker}"
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        resp = requests.get(f"{url}?modules=summaryProfile,defaultKeyStatistics,financialData",
                          headers=headers, timeout=10)
        data = resp.json()['quoteSummary']['result'][0]

        profile = data['summaryProfile']
        stats = data['defaultKeyStatistics']
        financials = data['financialData']

        return {
            'marketCap': profile.get('marketCap', {}).get('raw', 0),
            'revenueGrowth': financials.get('revenueGrowth', {}).get('raw', 0),
            'returnOnEquity': stats.get('returnOnEquity', {}).get('raw', 0),
            'debtToEquity': stats.get('debtToEquity', {}).get('raw', float('inf')),
            'averageVolume': profile.get('averageVolume', 0)
        }
    except Exception:
        return None

# Load tickers
print("Loading NASDAQ/NYSE tickers...")
nasdaq_url = "https://www.nasdaqtrader.com/dynamic/SymDir/nasdaqlisted.txt"
nyse_url = "https://www.nasdaqtrader.com/dynamic/SymDir/otherlisted.txt"

nasdaq_df = pd.read_csv(nasdaq_url, sep="|")
nyse_df = pd.read_csv(nyse_url, sep="|")

tickers = pd.concat([
    nasdaq_df['Symbol'].str.strip(),
    nyse_df['ACT Symbol'].str.strip()
]).dropna().unique().tolist()

# Filter likely small caps
tickers = [t for t in tickers if len(t) <= 5 and not t.startswith(('^', 'Z', 'BRK'))][:800]
print(f"Scanning {len(tickers)} tickers...")

# Screen
results = []
for i, ticker in enumerate(tickers):
    if i % 50 == 0:
        print(f"Progress: {i}/{len(tickers)} ({i/len(tickers)*100:.1f}%)")

    data = get_stock_data(ticker)
    if data and (3e8 <= data['marketCap'] <= 2e9 and
                 data['revenueGrowth'] > 0.20 and
                 data['returnOnEquity'] > 0.10 and
                 data['debtToEquity'] < 30 and
                 data['averageVolume'] > 500000):

        results.append({
            'Ticker': ticker,
            'Market Cap': data['marketCap'],
            'Revenue Growth': data['revenueGrowth'],
            'ROE': data['returnOnEquity'],
            'Debt/Equity': data['debtToEquity'],
            'Avg Volume': data['averageVolume']
        })

    time.sleep(0.1)  # Be nice to Yahoo

# Save results
df = pd.DataFrame(results)
filename = f"small_cap_picks_{datetime.now().strftime('%Y%m%d_%H%M')}.xlsx"
df.to_excel(filename, index=False)
print(f"\n🎯 Found {len(df)} qualifying small caps!")
print(df.round(3))

print(f"\nSaved to {filename}")
