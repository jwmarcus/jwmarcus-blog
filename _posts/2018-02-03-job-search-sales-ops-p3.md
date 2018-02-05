---
layout: post
title: 'Analyzing Prospecting Effectiveness'
date: 2018-02-03
---

# Analyzing Prospecting Effectiveness using Visualizations

_Quick links to other articles in this series:_

- [Part 1: Setup the process](/2018/02/01/job-search-sales-ops-p1.html)
- [Part 2: Establish metrics and a funnel](/2018/02/02/job-search-sales-ops-p2.html)
- [Part 3: Analyze prospecting effectiveness](/2018/02/03/job-search-sales-ops-p3.html)
- [Part 4: Scaling up efforts](/2018/02/04/job-search-sales-ops-p4.html)

I'm currently looking for a role in sales operations, preferably at a fast growing, technology-focused company. I figured as I'm so focused on business operations, I might as well use my sales-ops skills to drive my search. I documented the process in this article.

### Import

Import required libraries and set env variables


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

### Ingest

Read the dataset, rename the columns to something reasonable.


```python
df = pd.read_csv('./data/prospect_proforma.csv')

old_names = ['Int?', 'Contact Type', 'Outreach', 'Connect',
             'Stage', 'Reason', 'Intros?', 'FU Date',
             'Last ACT', 'Meetings', 'Email Address', 'LI Link',
             'Employees', 'Industry', 'First Name', 'Last Name',
             'Company', 'Position', 'Connected On', 'Tags']
new_names = ['INTERESTED','CONTACT_REASON','CONTACTED','CONNECTED',
             'STAGE','CLOSED_LOST_REASON','PROVIDED_INTROS','FOLLOWUP_DATE',
             'LAST_ACTIVITY','MEETING_STATUS','EMAIL','LI_LINK',
             'EMPLOYEES','INDUSTRY','FIRST_NAME', 'LAST_NAME',
             'COMPANY','POSITION','CONNECTED_ON','LI_TAGS']
df.rename(columns=dict(zip(old_names, new_names)), inplace=True)

df.columns.values
```




    array(['INTERESTED', 'CONTACT_REASON', 'CONTACTED', 'CONNECTED', 'STAGE',
           'CLOSED_LOST_REASON', 'PROVIDED_INTROS', 'FOLLOWUP_DATE',
           'LAST_ACTIVITY', 'MEETING_STATUS', 'EMAIL', 'LI_LINK', 'EMPLOYEES',
           'INDUSTRY', 'FIRST_NAME', 'LAST_NAME', 'COMPANY', 'POSITION',
           'CONNECTED_ON', 'LI_TAGS'], dtype=object)



## Question 1: Did I get the connection with the contacts that I reached out to?

Let's first get a count of where I both reached out and connected with people.


```python
count_contacted = len(df.loc[df['CONTACTED'] == 'Yes'])
count_connected = len(df.loc[df['CONNECTED'] == 'Yes'])
ratio_connected = count_connected / count_contacted
print("INFO: Connect rate on outreach: {0:.2f}%".format(ratio_connected * 100.))
```

    INFO: Connect rate on outreach: 84.38%


Hey, not bad! That's a pretty decent response rate, even for my immediate network.

## Question 2: Did the contacts I connected with turn into meetings?


```python
count_meetings = len(df.loc[df['STAGE'].notnull()])
ratio_meetings = count_meetings / count_connected
print("INFO: Meeting rate on connects: {0:.2f}%".format(ratio_meetings * 100.0))
```

    INFO: Meeting rate on connects: 38.89%


Ok, that's not too bad! 2 out of 5 people I connected with had a potential fit job for me.

## Question 3: Did those coffee meetings turn into interviews? Was the business interested in me and was I interested in the business?

This one is a bit tricker, as I have marked unqualified opportunities as "UQ" in the `Meeting_Status` column.


```python
# Be sure to wrap each conditional in () when using multiple selectors with df.loc[]

count_interviews = len(df.loc[(df['STAGE'].notnull()) & (df['STAGE'] != 'UQ')])
ratio_interviews = count_interviews / count_meetings
print("INFO: Interview rate on meetings: {0:.2f}%".format(ratio_interviews * 100.))
```

    INFO: Interview rate on meetings: 71.43%


That's actually really good! That means that there is mutual interest between my network and the types of jobs I would like to pursue.

## Question 4: Did the contacts I connected with refer me to someone else?

Are the amount of email replies consistent with the recorded number of nonnulls in df.PROVIDED_INTROS?


```python
# I'm using shorthand here for columns for a change of pace.
# It usually creates ambiquity with the capitalized CONSTANTS.

print(len(df.loc[df.CONNECTED.notnull()]) == len(df.loc[df.PROVIDED_INTROS.notnull()]))
```

    True



```python
count_introductions = len(df.loc[df.PROVIDED_INTROS == 'Yes'])
ratio_introductions = count_introductions / count_connected
print("INFO: Referral rate on connections: {0:.2f}%".format(ratio_introductions * 100.0))
```

    INFO: Referral rate on connections: 55.56%


Hmmm. Considering my contacts are well connected, I would expect a larger % of referrals.

## Question 5: How does variable 'XYZ' affect progression through the funnel?

Let's tag each of the columns by their stage for later plotting.


```python
# Kinda janky implementation here, as .apply returns Series, which imply doubles for certain fields

def tag_stages(row):
    # Did they make an interview?
    if row.notnull()['STAGE'] and row['STAGE'] != 'UQ':
        return 'INTERVIEW'

    # Did they make a meeting?
    elif row.notnull()['STAGE']:
        return 'MEETING'

    # Did they reply to email?
    elif row['CONNECTED'] == 'Yes':
        return 'CONNECTED'

    # Did I reach out to them?
    elif row['CONTACTED'] == 'Yes':
        return 'CONTACTED'

    else:
        return 'UNCONTACTED'


df['FUNNEL_STAGE'] = df.apply(tag_stages, axis = 1)

print(df['FUNNEL_STAGE'].value_counts())
```

    UNCONTACTED    1686
    CONNECTED        33
    INTERVIEW        15
    CONTACTED        10
    MEETING           6
    Name: FUNNEL_STAGE, dtype: int64


Take note that contacts can only be in one stage at a time. The funnel will need to take into account of this.

# Plotting results in a visual format

Now that we have some rudimentary information on our data, let's dig into some plots to try to draw some visual trends.

## Making a funnel

> Note: There are a million ways to build a funnel. There are even fancy packages out there to do it for you (for a price). For this project, I just built an array of tuples and threw it into Seaborn because it's nice looking.

First, let's map each of these text values to numberical values to make life easier.


```python
mapping = {'CONTACTED': 1, 'CONNECTED': 2, 'MEETING': 3, 'INTERVIEW': 4}
df['FUNNEL_STAGE_INT'] = df['FUNNEL_STAGE'].map(mapping)
```

Now, aggregate it into a nice `funnel` object we can plot.


```python
def get_stage_count(stage_int):
    return df[df['FUNNEL_STAGE_INT'] >= stage_int]['FUNNEL_STAGE_INT'].count()

stages = []
for i in range(1, 5):
    stages.append((i, get_stage_count(i)))

print(stages)
```

    [(1, 64), (2, 54), (3, 21), (4, 15)]


## Assembling the charts


```python
# rc-level style changes
# mpl.rcParams['figure.figsize'] = (10, 6)

# Set figure (outer wrapper) parameters
plt.figure(figsize=(10, 6))

# With only one plot (no sub-plots), axis limits and titles will apply to the only plot
plt.ylim(0,70)
plt.xlim(0.5, 4.5)

# Sweet one-liner for unpacking a list and then passing it into the plot function
plt.plot(*zip(*stages))

# Neat trick we can use for labels because we used numbered values for our stages before
plt.xticks(range(1, 5), sorted(mapping, key=mapping.get))

# Be DESCRIPTIVE with your labels!
plt.title('Contact Count by Pipeline Stage')

plt.show()
```


![png](/img/posts/20180203_output_33_0.png)


Neat! That looks decent enough.

## Company sizes in funnel

Let's take a look at the distribution of company sizes throughout the funnel. Again, we'll map to integers to make things easier to calculate and order later.


```python
employee_mapping = {'1-10': 1, '11-50': 2, '51-200': 3,
                   '201-500': 4,'501-1000': 5, '10,000+': 6}
df['FUNNEL_EMPLOYEES_INT'] = df['EMPLOYEES'].map(employee_mapping)
```

And again, let's pull out the totals from **ONLY** our interviewed data set. I didn't add company info for companies I didn't reach out to as I did it manually.


```python
def get_count_by_company_size(company_size_int):
    return df[(df['FUNNEL_EMPLOYEES_INT'] == company_size_int)]['FUNNEL_EMPLOYEES_INT'].count()

employee_sizes = []
for i in range(1, 7):
    employee_sizes.append((i, get_count_by_company_size(i)))

print(employee_sizes)
```

    [(1, 11), (2, 26), (3, 9), (4, 4), (5, 1), (6, 3)]


### Plotting time!


```python
# This is the same as above, but looking across employee buckets
plt.figure(figsize=(10, 6))
plt.ylim(0,30)
plt.xlim(0.5, 6.5)
plt.plot(*zip(*employee_sizes))
plt.xticks(range(1, 7), sorted(employee_mapping, key=employee_mapping.get))
plt.title('Contact Count by Company Employee Size')

plt.show()
```


![png](/img/posts/20180203_output_41_0.png)


Hmmm... That means most of my contacts are at the 11-50 level. That's a bit lop-sided considering the director / VP level role I'm aiming for, which tends to be at slightly larger companies in these buckets.

## More data science, let's get to digging

Maybe the graph between the company size and the stage might light some insight


```python
def get_employee_count_by_stage(contact):
    return (contact['FUNNEL_EMPLOYEES_INT'], contact['FUNNEL_STAGE_INT'])

employees_by_stage = []
for _, contact in df[df['FUNNEL_EMPLOYEES_INT'].notnull()].iterrows():
    employees_by_stage.append(get_employee_count_by_stage(contact))

print(employees_by_stage[:5])
```

    [(2.0, 3.0), (3.0, 2.0), (2.0, 3.0), (2.0, 2.0), (2.0, 2.0)]



```python
# More figure and scale setup
plt.figure(figsize=(10, 8))
plt.ylim(-0.5, 5.5)
plt.xlim(-0.5, 7.5)

# Seaborn likes explicit passes for params
x, y = map(list, zip(*employees_by_stage))

# Let seaborn shine!
ax = sns.kdeplot(x, y, n_levels=20, cmap="GnBu_d")

plt.xticks(range(1, 7), sorted(employee_mapping, key=employee_mapping.get))
plt.yticks(range(1, 5), sorted(mapping, key=mapping.get))
plt.title('Contact Density by Company Employee Size and Stage')
plt.show()
```


![png](/img/posts/20180203_output_46_0.png)


**NOW** we're talking. There is a distinct ridge going up the 11-50 longitude. However, there is a soft ridge east of the north peak where there is a potential for 51+ employee companies to make it to a later stage in the process. The issue is that there aren't that many companies in the funnel at the early stages to make it to the interview process. That means it's time to fill that funnel with 50+ employee companies (preferrably 200+ for stage 2 of our process.

[Click here](/2018/02/04/job-search-sales-ops-p4.html) for part 4.
