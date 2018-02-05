---
layout: post
title: 'Establishing Metrics and a Funnel for a Job Search'
date: 2018-02-02
---
# Establishing Metrics and a Funnel for a Job Search

_Quick links to other articles in this series:_

- [Part 1: Setup the process](/2018/02/01/job-search-sales-ops-p1.html)
- [Part 2: Establish metrics and a funnel](/2018/02/02/job-search-sales-ops-p2.html)
- [Part 3: Analyze prospecting effectiveness](/2018/02/03/job-search-sales-ops-p3.html)
- [Part 4: Scaling up efforts](/2018/02/04/job-search-sales-ops-p4.html)

I'm currently looking for a role in sales operations, preferably at a fast growing, technology-focused company. I figured as I'm so focused on business operations, I might as well use my sales-ops skills to drive my search. I documented the process in this article.

## Data analysis of Phase 1

Now comes the fun part where we look at the results from a few weeks of emailing, phone calls, meetings and interviews. I could have used a few different tools for this part, but I chose to work in work in [Jupyter / iPython notebook][jupyter] and to use [Seaborn][seaborn] for data visualization. I only did this for fun, as you could generate these charts in most any software like Excel or Google Sheets. The important thing is to **ask questions of your data, and use the answers to change future behavior and processes.**

At this stage, a lot of sales operations experts screw up by letting the data drive the questions. This is a terrible idea in most cases. It's better to learn through analysis that you don't have the data to answer a business question than it is to fit the question to the data. By learning that you don't have the right data, you gain an opportunity to change the process for the better. You should also look closely at the question you're trying to answer and determine whether or not an answer would drive actual change. Simply asking questions and not changing behavior based on the answer is not only rude to your sales ops professional, but is a complete waste of time. Be ready to embrace change when you go digging into a dataset.

### Funnel analysis

I had a few questions going through my head as I looked through the results of phase 1. I'll outline them below with some data to support an insight.

> Did my outreach emails work or not work? Did I get the connection with the contacts that I reached out to?

I generated a funnel using the graphing toolkit and some basic parsing using the stages I put earlier into my proto-CRM (good preparation is always the key). Based on those results, I'm pretty impressed at the response rate. I did selectively pick out these people due to my relationships with them, but that's still a good number given how high up in the organization most of my contacts are.

> Did the contacts I connected with turn into meetings?

I wasn't sure what to think of this answer, as I didn't track how many of my contacts had open requisitions to fill. I think if I did some scraping for open postings I would have had a higher number of initial meetings.

> Did those coffee meetings turn into interviews? Was the business interested in me and was I interested in the business?

There are a few ways that I disqualified an opportunity. Sometimes the chemistry was wrong and the company and I weren't a fit. Other times the compensation or work to be done were way off the mark for the work to be done. Mostly it came down to Budget. A lot of these companies I looked at are smaller, and they don't always have the head-count available for a head of sales operations. Maybe I need to look at the companies themselves.

> Did the contacts I connected with refer me to someone else?

I would say that this part was a resounding success. Many of these referrals were a bit off the mark, and only a few turned into interviews, but I was trying to optimize for referrals, not interviews. After looking at the data, it looked like I needed to optimize around interviews, not just sheer velocity.

> How does XYZ variable affect progression through the funnel?

I thought it would be interesting to get a feel for how some of the other features affect how deep into the funnel each of these contacts get. A few plots will take care of this.

## Moving on to data analysis

After looking through all of the data, it was time to put phase 2 into action. Time to take those learnings and make a change to the process.

[Click here](/2018/02/03/job-search-sales-ops-p3.html) for part 3.

[seaborn]: https://seaborn.pydata.org/
[jupyter]: http://jupyter.org/
