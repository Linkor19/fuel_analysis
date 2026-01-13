import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

AZSinfluence = pd.read_excel('Data/AZSinfluence.xlsx')
LocationInfluence = pd.read_excel('Data/LocationInfluence.xlsx')
RangeInfluence = pd.read_excel('Data/RangeInfluence.xlsx')
RangeInfluence = RangeInfluence[RangeInfluence['TotalCardOrders']>3]


# meanPremAZS = AZSinfluence['PremRatio'].mean()
# AZSinfluence = AZSinfluence[AZSinfluence['PremRatio'] > meanPremAZS]
# meanPremloc = LocationInfluence['PremRatio'].mean()
# LocationInfluence = LocationInfluence[LocationInfluence['PremRatio'] > meanPremloc]
# meanPremreg = RangeInfluence['PremRatio'].mean()
# RangeInfluence = RangeInfluence[RangeInfluence['PremRatio'] > meanPremreg]

tables_dict = {
    'AZS': AZSinfluence,
    'Location': LocationInfluence,
    'Range': RangeInfluence
}

for name, df in tables_dict.items():
    df["Z_PremRatio"] = (df["PremRatio"] - df["PremRatio"].mean()) / df["PremRatio"].std()
    df = df[df["Z_PremRatio"] > 0]
    df["Z_DemandChanges"] = (df["DemandChanges"] - df["DemandChanges"].mean()) / df["DemandChanges"].std()
    df["Z_weighted_impact"] = 0.5 * df["Z_PremRatio"] + 0.5 * df["Z_DemandChanges"]
    print(df[[name, "Z_PremRatio", "Z_DemandChanges", "Z_weighted_impact"]].sort_values('Z_weighted_impact',
                                                                                    ascending=False).head(30))
    df["Z_weighted_impact"].hist(bins=10)
    # plt.show()
    print(df["Z_weighted_impact"].agg(["sum", "mean"]))

for name, df in tables_dict.items():
    df["Z_PremRatio"] = (df["PremRatio"] - df["PremRatio"].mean()) / df["PremRatio"].std()
    df = df[df["Z_PremRatio"] < 0]
    df["Z_DemandChanges"] = (df["DemandChanges"] - df["DemandChanges"].mean()) / df["DemandChanges"].std()
    df["Z_weighted_impact"] = 0.5 * df["Z_PremRatio"] + 0.5 * df["Z_DemandChanges"]
    print(df[[name, "Z_PremRatio", "Z_DemandChanges", "Z_weighted_impact"]].sort_values('Z_weighted_impact', ascending=False))
    df["Z_weighted_impact"].hist(bins=10)
    # plt.show()
    print(df["Z_weighted_impact"].agg(["sum", "mean"]))



