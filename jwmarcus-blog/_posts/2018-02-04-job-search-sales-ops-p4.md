---
layout: post
title: 'Scaling up Prospecting, Web Scraping for Fun and Profit'
date: 2018-02-04
---

# Scaling up Prospecting, Web Scraping for Fun and Profit

_Quick links to other articles in this series:_

- [Part 1: Setup the process](/2018/02/01/job-search-sales-ops-p1.html)
- [Part 2: Establish metrics and a funnel](/2018/02/02/job-search-sales-ops-p2.html)
- [Part 3: Analyze prospecting effectiveness](/2018/02/03/job-search-sales-ops-p3.html)
- [Part 4: Scaling up efforts](/2018/02/04/job-search-sales-ops-p4.html)
- [Part 5: Evaluating the results](/2018/02/05/job-search-sales-ops-p5.html)

I'm currently looking for a role in sales operations, preferably at a fast growing, technology-focused company. I figured as I'm so focused on business operations, I might as well use my sales-ops skills to drive my search. I documented the process in this article.

## Import handy libraries


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

## Phase 2, expanding the job search

For this phase, we're going to take a more broad approach to finding qualified roles in companies in my area of expertise. First, we need a list of the top job aggregators online [SOURCE](https://www.thebalance.com/top-best-job-websites-2064080). In addition, there are a few [niche job sites](https://www.thebalance.com/top-niche-job-sites-2061866) that might also be good fits.


```python
# Mainstream Job Sites
job_sites = ['https://www.indeed.com/',
'https://www.careerbuilder.com/',
'https://www.dice.com/jobs',
'https://www.glassdoor.com/index.htm',
'https://www.google.com/search?q=jobs',
'https://linkup.com/',
'https://www.monster.com/'
]

# Niche Sites
job_sites_niche = ['https://www.salesjobs.com/',
'https://www.salesgravy.com/JobBoard/',
]
```

Let's take a look at some search results from a few of the sites:

> Director, Global Sales and Channel Operations  
> Rapid7 - 21 reviews - Boston, MA  
> Rapid7 is seeking to recruit an experienced sales operations professional for the position of Director, Global Sales and Channel Operations to lead...

Well, that's not very helpful. It seems like a pretty manual process. Maybe I can export everything in one go? How many results are we talking about on the top site?

> Page 1 of 504 jobs

With 9 sites and < 500 jobs each site  (average of 150, let's say) that's 1,350 posts at a maximum to review. How long does it take me to review one of these posts?


```python
# Yes, I timed how long it took me to read and categorize job postings
review_times = [16.76, 13.23, 16.26, 10.70, 17.49, 10.33]
max_postings = 1350
mean_review_time = np.mean(review_times)

print('Average post review: {:.2f} seconds'.format(mean_review_time))
print('Total time to review {} posts: {:.1f} hours'.format(max_postings, mean_review_time * max_postings / 60 / 60))
```

    Average post review: 14.13 seconds
    Total time to review 1350 posts: 5.3 hours


**Hmmm...**

That would be a painful 5.3 hours of looking at a screen. Do any of these guys have APIs?

- Indeed.com has [one for publishers](https://www.indeed.com/publisher), so let's apply for an API key so we can export everything. Looks like a sales call will be involved. That wouldn't be worth the time.
- CareerBuilder.com has one that [seems pretty friendly](https://developer.careerbuilder.com/docs/v3jobid). Let's apply for a key there too. OH WAIT, they have a closed API that requires a sales call and a business agreement. **Nevermind.**
- Dice.com had an API, but there is no way to get a developer key. The page listed on their [Programmable Web page](https://www.programmableweb.com/api/dice-jobs) has lots of 404's and CURLing the engpoint comes back requiring a key.

Man, this developer experience is GARBAGE. _\*cracks knuckles\*_ Fine then. We'll play this the hard way. Time to do some surgery with some 60 year old tech: regular expressions.

## Regex Patterns for fun and profit

I'm going to need to export the pages into files that I can parse. Luckily, I only need the html or the response JSON to get the job post text. Alternatively, I can just do some hacking in-page and load up jQuery and pick apart the fields that I want and export them to JSON.

The strategy is going to vary based on the website in question. If the target relies on a staic application to serve content, I can simply intercept any traffic over the network via the XHR tab. If the pages are a bit more complex, I can copy all the HTML and then rip through them using something like [ATOM](https://atom.io/)

Once I have all the job posting URLs, I can use Python `requests` to pull down the pages themselves (and then gut them with RegEx).

**But first...**

Let's figure out what we need to extract from these job postings. In our last post, we discovered that certain sizes of companies are actually better fits with my job search goals. That means that we need at the very minimum:

- Company Employees (via LinkedIn)

And to make sure we can get at that information, we could use any of the following:

- Company Name
- Annual Revenue (approx $100k Revenue / FTE)

Next, we want to get some information about the role being hired for:

- Job Title
- Location
- Salary
- Original Posting Date

That should be a good start. Let's dig into some code, how about we start with dice.com?

### JQuery snipping

1. Snip out the HTML that cooresponds to each position.

```
listings = $('.complete-serp-result-div')
listings.each(function(index) {console.log('RESULT #' + index + $(this).html())});
```

which gives us...

```
RESULT #29
<div class="serp-result-content bold-highlight">
<input type="hidden" id="featureId61cd968cb94c2a4c9637285f8f9aa99a" value="false">					
<div class="logo-section  hidden-xs">
<div class="logopath">
```

Nice! Now let's repeat that for each page (manually) and throw all of that HTML into a text file called dice_results.raw.txt. I cleaned up all the extra cruft with tabs and leading spaces and garbage using `vim`:


`:%s/^\t\+//g # remove tabs at the start of the line`

`:%s/^$\n//g # remove empty lines, from 80k lines to 36k lines`

Phew, now that is complete: Let's go in and extract those fields we want using python's string functions.

## Data extraction

First, let's find a way to extract the positions, then we can repeate with a bunch of others:

`cat dice_results.html | grep -P "position[0-9]+" | wc -l`

= 478. Not a bad haul for 15 minutes of web scraping. Let's get the actual titles.

`cat dice_results.html | grep -Po "position[0-9]+.*title=\K\".*?\"" > dice_job_titles.html`

`head -n 10 dice_job_titles.html`

    "Oracle Application Architect"
    "Sr. Enterprise Data Modeler"
    "Eagle Support Business Analyst"
    "Business Analyst (With PM Background)"
    "Active Directory Architect"
    "DevOps Engineer - (No C2C Resumes)"
    "Eagle Support Business Analyst"
    "Senior Manager of Quality Insurance"
    "Mainframe Consultant (db2-jcl)"
    "Data Governance Lead"

Niiiiice. Let's do the same for some other fields and drop them all into a spreadsheet. It looks like the company name is actually buried on the alt tag for the company logo. Let's grab that now.

`cat dice_results.html | grep -Po "href=\"/company/.*alt=\K\".*?\"" > dice_company_names.html`

`head -n8 dice_company_names`

    "Advancement Alternatives"
    "STRIVE Consulting"
    "Wipro Ltd."
    "Incendia Partners"
    "Elevate Technology Solutions"
    "CyberCoders"
    "Gardner Resources Consulting, LLC"
    "Zeva Technology"

### Minor setback, fiddling with regex

**Crap** the line counts are different. Gotta find a different way of getting that company name. No worries, I can use a different tag for that:

`cat dice_results.html | grep -Po "compName\" itemprop=\"name\">\K[-.,A-Za-z0-9 ]+" | awk '{print "\""$0"\""}' > dice_companies.txt`

Ok, enough showboating with one-liners, did the results match?


```python
478 == 478
```




    True



Sweet, nailed it. I'll spare you some reading and do the rest of the fields I'm interested in separately.

### Data analysis of prospect quality

Finally, I smash it all together in a csv using:

`paste -d "," dice_job_titles.txt dice_companies.txt > dice_combined.csv`

Now I can load it up!


```python
df = pd.read_csv('./data/dice_combined.csv', names=['Job_Title', 'Company_Name', "Post_URL"])
df.head(3)
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
      <th>Job_Title</th>
      <th>Company_Name</th>
      <th>Post_URL</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Senior Sales Executive - Managed Services</td>
      <td>CyberCoders</td>
      <td>/jobs/detail/Senior-Sales-Executive-%26%2345-M...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Sales Effectiveness - Banking and Securities M...</td>
      <td>Deloitte</td>
      <td>/jobs/detail/Sales-Effectiveness-%26%2345-Bank...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Director, Enterprise Operations &amp;amp; Support</td>
      <td>Tufts University</td>
      <td>/jobs/detail/Director%2C-Enterprise-Operations...</td>
    </tr>
  </tbody>
</table>
</div>



Sweet, now before we do some clicking on LinkedIn to get company sizes, let's look at this distribution. It seems like there are a few companies skewing the numbers a bit:

```
Unique Company	Count
CyberCoders 70
Deloitte 34
National Grid 61
Capital Markets Placement 21
The Judge Group	13
```

Just as I thought. Most of the jobs on this job board **are by placement agencies**. Grrr. Man, that's upsetting and disheartening.

Given such, here is the breakdown of the postings by techincal recruiter vs direct listing:


```python
labels = ['Recruiter', 'Company Hire']
plt.figure(figsize=(7, 7))
recruiter_dist = [230, 248]
plt.pie(recruiter_dist, labels=labels)
plt.title('Posting on Dice.com by Origin Type')
plt.show()
```


![png](/img/posts/20180204_output_26_0.png)


Excluding the recruiter sourced jobs, how many of these positions are a fit for what I'm looking to do? Let's see:


```python
df_pp = pd.read_csv('./data/prospect_proforma_phase_2.csv', names=[
                    'Job_Title', 'Company_Name', 'Fits_Goals', 'Mass_Hire','URL'])
df_pp.head(5)
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
      <th>Job_Title</th>
      <th>Company_Name</th>
      <th>Fits_Goals</th>
      <th>Mass_Hire</th>
      <th>URL</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Job_Title</td>
      <td>Company</td>
      <td>Fits Goals</td>
      <td>Desperate/Recruiter Hiring</td>
      <td>Posting URL</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Senior Sales Executive - Managed Services</td>
      <td>CyberCoders</td>
      <td>0</td>
      <td>1</td>
      <td>/jobs/detail/Senior-Sales-Executive-%26%2345-M...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Sales Effectiveness - Banking and Securities M...</td>
      <td>Deloitte</td>
      <td>0</td>
      <td>1</td>
      <td>/jobs/detail/Sales-Effectiveness-%26%2345-Bank...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Director, Enterprise Operations &amp;amp; Support</td>
      <td>Tufts University</td>
      <td>1</td>
      <td>0</td>
      <td>/jobs/detail/Director%2C-Enterprise-Operations...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Sales Engineer III - Boston</td>
      <td>CenturyLink</td>
      <td>0</td>
      <td>0</td>
      <td>/jobs/detail/Sales-Engineer-III-%26%2345-Bosto...</td>
    </tr>
  </tbody>
</table>
</div>




```python
total_job_count = len(df_pp)
fitting_jobs = len(df_pp.loc[df_pp['Fits_Goals'] == "1"])
percent_fit = (fitting_jobs / total_job_count) * 100.

print("{:.2f}% of total postings match job requirements.".format(percent_fit))
```

    2.71% of total postings match job requirements.


Oh man, that's pretty sad. Let's get to harvesting as much as we can and then we can move onto the next phase, which is matching the available postings to the correct company sizes.
