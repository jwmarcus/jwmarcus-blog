---
layout: post
title: 'Evaluating Web Scraping Yield in a Job Search'
date: 2018-02-05
---

# Evaluating Web Scraping Yield in a Job Search

_Quick links to other articles in this series:_

- [Part 1: Setup the process](/2018/02/01/job-search-sales-ops-p1.html)
- [Part 2: Establish metrics and a funnel](/2018/02/02/job-search-sales-ops-p2.html)
- [Part 3: Analyze prospecting effectiveness](/2018/02/03/job-search-sales-ops-p3.html)
- [Part 4: Scaling up efforts](/2018/02/04/job-search-sales-ops-p4.html)
- [Part 5: Evaluating the results](/2018/02/05/job-search-sales-ops-p5.html)

I'm currently looking for a role in sales operations, preferably at a fast growing, technology-focused company. I figured as I'm so focused on business operations, I might as well use my sales-ops skills to drive my search. I documented the process in this article.

---

OK. Now that we have a bunch of results pulled from the web, let's try to make sense of what we're looking at. This will be a speed-round of data analysis.


```python
# Number packages
import numpy as np
import scipy
import pandas as pd

# Graphics packages
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns

%matplotlib inline

# Tell graphs to look nice
sns.set_style('darkgrid')
```

Load up data set.


```python
df = pd.read_csv('./data/prospect_proforma_phase_3.csv')
df.head(5)
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Job</th>
      <th>Interest?</th>
      <th>Company</th>
      <th>Dupe</th>
      <th>Employees</th>
      <th>Source</th>
      <th>Link</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Boston Job Fair - February 5 - LIVE HIRING EVE...</td>
      <td>0</td>
      <td>Coast-to-Coast Career Fairs</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>CareerBuilder</td>
      <td>http://www.careerbuilder.com/job/JJJ66R684VZMQ...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Salesforce Developer</td>
      <td>0</td>
      <td>CyberCoders</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>CareerBuilder</td>
      <td>http://www.careerbuilder.com/job/J3S2D771LCK7P...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Director of Operations</td>
      <td>1</td>
      <td>GPAC</td>
      <td>0.0</td>
      <td>51-200</td>
      <td>CareerBuilder</td>
      <td>http://www.careerbuilder.com/job/J3R2ZX72NS024...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Controller</td>
      <td>0</td>
      <td>Kforce Finance and Accounting</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>CareerBuilder</td>
      <td>http://www.careerbuilder.com/job/J3V5S05W2QB68...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Revenue Finance Manager (Software Co)</td>
      <td>0</td>
      <td>Kforce Finance and Accounting</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>CareerBuilder</td>
      <td>http://www.careerbuilder.com/job/J3N0YY6LPBC5G...</td>
    </tr>
  </tbody>
</table>
</div>



## Q1. Where did most of the job postings come from?


```python
source_counts = df['Source'].value_counts()

plt.figure(figsize=(7, 7))
plt.pie(source_counts, labels=source_counts.index)
plt.title('Job Posting Distribution by Source')
plt.show()
```


![png](/img/posts/20180205_output_6_0.png)


**Comments:** I was suprised how many jobs came from Dice. We will need to see what makes it through the next few filters.

## Q2. What were the most productive job sources?


```python
source_counts_kept = df[(df['Interest?'] == 1) & (df['Dupe'] == 0)]['Source'].value_counts()
source_yield = (source_counts_kept / source_counts * 100.).sort_values(ascending=False)

print(source_yield)
```

    CareerBuilder    30.000000
    Monster          14.241486
    GlassDoor        11.486486
    Google Jobs       9.090909
    LinkUp            8.866995
    Indeed            4.687500
    Dice.com          0.836820
    Name: Source, dtype: float64


**Comments:** LinkUp was actually more productive than originally expected. GlassDoor was **WAY** more productive than expected. Hat tip to those guys and gals for making some great search software. Dice not only returned bad results, but had plenty of duplicate postings too. Monster did a good job of both producing good results and not presenting duplicates.

## Q3. What is the company size distribution for SAL (sales accepted lead) job postings?


```python
employee_mapping = {'1-10': 1, '11-50': 2, '51-200': 3,
                    '201-500': 4,'501-1000': 5, '1001-5000': 6, 
                    '5001-10,000': 7, '10,000+': 8}

df['FUNNEL_EMPLOYEES_INT'] = df[(df['Interest?'] == 1) & (df['Dupe'] == 0)]['Employees'].map(employee_mapping)

def get_count_by_company_size(company_size_int):
    return df[(df['FUNNEL_EMPLOYEES_INT'] == company_size_int)]['FUNNEL_EMPLOYEES_INT'].count()

employee_sizes = []
for i in range(1, 9):
    employee_sizes.append((i, get_count_by_company_size(i)))

print(employee_sizes)
```

    [(1, 4), (2, 4), (3, 9), (4, 16), (5, 14), (6, 18), (7, 13), (8, 5)]


Data looks good, let's plot it.


```python
plt.figure(figsize=(10, 6))
plt.ylim(0,25)
plt.xlim(0.5, 9.0)
plt.plot(*zip(*employee_sizes))
plt.xticks(range(1, 9), sorted(employee_mapping, key=employee_mapping.get), rotation='vertical')
plt.title('Accepted Job Posting Count by Company Employee Size')

plt.show()
```


![png](/img/posts/20180205_output_14_0.png)


**Comments:** This is absolutely AWESOME. This is EXACTLY what I hoped to get from my high-velocity search process. The employee size is spot on, the distribution skews toward larger companies (per part 3 of this series), and the quantity of companies in the optimal range is higher than expected. This made my day.

## What's next?

Now, I need to submit my resume to over 100 different job opportunities while at the same time managing my existing funnel of interviews. In all honesty, that's the easy part!

I will say: looking for a perfect job is hard. Hopefully this series of posts was helpful in outlining my thought process and maybe you were able to glean some learnings from this series.

My deepest thanks goes to the folowing people for helping with this job search and data science series:

- [Ryan Plunkett](https://www.linkedin.com/in/ryan-plunkett-87b06254/) for _competitively_ introducting me to Seaborn and Jupyter.
- [Mike Redbord](https://www.linkedin.com/in/mredbord/) for encouraging me to write all this down.
- [Dezrah Blinn](https://www.linkedin.com/in/scottdezrahblinn/) for his infectious positivity in the job search, even as he changes careers himself.
