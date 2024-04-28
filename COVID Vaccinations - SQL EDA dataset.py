#!/usr/bin/env python
# coding: utf-8

# In[7]:


import pandas as pd
import numpy as np
import seaborn as sns

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure


# In[2]:


# Read in the data

df = pd.read_csv(r'C:\Users\toluf\OneDrive\Desktop\DA - Project\COVID project\CovidVaccinations.csv')


# In[3]:


df.head()


# In[4]:


df.isna()


# In[5]:


df.loc[df.duplicated()]


# In[6]:


df.describe()


# In[8]:


df.plot(kind='scatter', x='new_tests',
       y='people_vaccinated')


# In[ ]:




