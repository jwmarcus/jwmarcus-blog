---
layout: post
title: 'Using Sales Operations Skills for Job Hunting'
date: 2018-02-01
---
# Using Sales Operations Skills for Job Hunting

_Quick links to other articles in this series:_

- [Part 1: Setup the process](/2018/02/01/job-search-sales-ops-p1.html)
- [Part 2: Establish metrics and a funnel](/2018/02/02/job-search-sales-ops-p2.html)
- [Part 3: Analyze prospecting effectiveness](/2018/02/03/job-search-sales-ops-p3.html)
- [Part 4: Scaling up efforts](/2018/02/04/job-search-sales-ops-p4.html)
- [Part 5: Evaluating the results](/2018/02/05/job-search-sales-ops-p5.html)

I'm currently looking for a role in sales operations, preferably at a fast growing, technology-focused company. I figured as I'm so focused on business operations, I might as well use my sales-ops skills to drive my search. I documented the process in this article.

## Preliminary work

It should go without saying but I will be explicit: a solid resume, [LinkedIn profile][li-profile] and [personal website][personal-website] go a long way toward putting forward a professional image. I rewrote my resume eight times after consulting six of my closest friends and mentors for feedback. **Do the preliminary work so when it comes time to actually do the operational work, you'll be ready.**

Planning is critical for any good job search. If you just throw spaghetti at the wall, not much will stick unless you are both really sought after and lucky. For my search, I broke it into two phases: (1) personal network mining and (2) a wide network search by functional role. I had some rough targets in terms of metrics for myself but I was coming into the process with eyes wide open. I decided to follow a standard sales process funnel for my job search process, which I outlined below.

## Generating a list of work and personal connections

For the first phase of my search, I used all of my existing contacts on LinkedIn to search for both job opportunities as well as introductions to other people one connection removed. I have a separate database of personal connections within Google Contacts, but I wanted to focus on individuals with whom I have previous business relationships. To start, I exported my LinkedIn contacts by following [this article][li-export]. I put all of these into Google Sheets as it will serve as my quick and dirty CRM. Could I have spun up a SugarCRM instance? Sure, but **with any system, there is always a balance between getting it perfect and getting it done.**

Next, I needed to clean and augment the data. Some contacts had outdated LinkedIn profiles, so I needed to update those where appropriate. I could have used some fancy regex to compare current email addresses to the names of the companies the contact is working for, but I just looked through all 1750 contacts in an afternoon. It was nice to see what everyone in my network was up to these days.

I picked a selection of 64 contacts that I felt I had earned the right to ask for a referral. I then needed to augment the data with company industry and size as I'm focused on earlier stage companies. I added a "quick link" so I can just click and open new LinkedIn windows:

1. Get base URL for LinkedIn Company Search - `https://www.linkedin.com/search/results/companies/?keywords=`
2. Append with Company field (Column "P" in my case) - `CONCATENATE("https://www.linkedin.com/search/results/companies/?keywords=", P26)`
3. Create click-able, short link: - `=HYPERLINK(CONCATENATE("https://...", P26), "CLICK ME")`
4. Fill down `CMD/WIN + D` the rest of the column
5. `CTRL + Click` each of the cells to open new tabs

Considering I only had a few dozen contacts to augment, I just manually added this information to the spreadsheet. **It is generally unwise to automate processes that are (1) rapidly changing, (2) ambiguous or (3) small in scale.** Now that I have some contacts, let's start reaching out!

## Prospecting into the contact database

The end goal of phase 1 is to get my contacts introduce me to someone who might be hiring for my role. However, there are some contacts that are also hiring for operations leaders. That means I need an outreach template that either has multiple branches or multiple outreach templates. Considering that I know all of these people professionally and personally, I chose a multi-clause template based on my best performing sales emails from my consulting business. I used templates, but I personally crafted each email to the contact I was emailing. After all, **good sales operations starts with a mindset rooted in good sales.**

After that, I sent the emails and made phone calls where appropriate and scheduled coffee meetings and/or drinks with all follow-ups that might have a role for me. Any new contacts from introductions were added to the spreadsheet.

![](/img/posts/20180201_ss.png)

I won't bore you with the actual meeting and interview strategy, so instead I want to look at the results I got so far. In the next part, we'll dive into the results from a few weeks of prospecting.

[Click here](/2018/02/02/job-search-sales-ops-p2.html) for part 2.

[li-profile]: https://www.linkedin.com/in/jwmarcus/
[personal-website]: http://www.jwmarcus.com
[li-export]: https://www.linkedin.com/help/linkedin/answer/66844/exporting-connections-from-linkedin?lang=en
