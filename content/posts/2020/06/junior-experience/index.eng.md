---
title: My First Month at Planetarium
date: 2020-06-02
authors: [suho.lee]
translators: [kidon.seo]
---

Hello, I’m Suho Lee, the newest member of Team Libplanet at [Planetarium]. To celebrate my first month of working in the company, I would like to take this opportunity to talk about my expectations joining the team, what I did for a month, and how we work at Planetarium. 

[Planetarium]: https://planetariumhq.com/

How I Applied to Planetarium
----------------------------

In June 2019, I participated in an event called [2019 Sprint Seoul]. While deciding which open-source project to contribute to, Hong Minhee, a member of Planetarium reached out to me and suggested me to take a look at [Libplanet]. My experience contributing to Libplanet turned out to be extremely memorable and I decided to apply for a job at Planetarium as soon as open positions were posted. My main motivation for applying was that I wanted to continue this positive experience working with the members at Planetarium and I also wanted to make an impact in the company by sharing my positivity.

[2019 Sprint Seoul]: https://www.sprintseoul.org/2019-06-29/
[Libplanet]: https://libplanet.io/ 

What I Did in the First Month
-----------------------------
During the first month, I spent most of my time reviewing the structure of Libplanet and C#. I developed Libplanet from scratch to a <abbr title="proof of concept">PoC</abbr> level to get a deeper understanding of the project. Also, every time I was introduced to a module, I fixed issues in that module to further my understanding. 

{{<
figure
  src="images/resolved-issue.png"
  caption="List of Fixed Issues in the First Month"
>}}

Personally, I felt that this was a very effective way of understanding the material within a short amount of time. Because overall briefings on project structure and modules are quite conceptual in general, it was my job to dive deeper into the concepts and to understand how things work in low-level. Therefore, going head first and experiencing the workings of the project directly by solving real-issues really helped me solidify the concepts in and out.

I also personally started writing daily reports on my work. 

{{<
figure
  src="images/daily-reports.png"
  caption="List of Daily Reports"
>}}

{{<
figure
  src="images/daily-report.png"
  caption=" Daily Report"
>}}

The reason for making daily reports a habit was to get the most out of our *daily meetings*.

Meeting Culture
---------------
Team Libplanet holds 3 types of meetings.

- Daily Meetings
- Weekly Meetings
- Quarterly Retrospectives

Among them, <dfn>daily meetings</dfn> (<dfn>daily</dfn> in short) are held at 2pm every day to share what we are currently working on. In general, when someone goes into a ‘deep dive mode,’ it’s very easy to find oneself overengineering until someone else tells you so. The daily meetings work to prevent each other from going overboard and help each other out by giving updates to our work progress. Personally, keeping a daily report for these meetings has helped me objectify my work progress which in turn has helped with the work itself.

Typically, daily meetings can turn into *show me evidence that you are really working* type of meetings (ex: teams with vertical hierarchy). However, I’ve noticed that our team’s daily meetings are not for exaggerating our progress but are mainly used for updating each other with things that aren’t working out and things that we aren’t sure about— this is what I really liked about our culture.

Members that Walk the Talk
--------------------------
Everyone knows that it’s meaningless to hold a person responsible for failure in decision making. So we are taught that if you fail, you should share and get feedback quickly, and find an alternative. But it's not as easy as it sounds.

Not long after I came in, our team was in the middle of creating a small GUI app that works on both Windows and macOS. We ended up realizing that the cross-platform GUI framework that we decided to use 15 days ago was not suitable for the problem we were trying to solve entirely. However, because the person working on the project focused on solving the issue at hand, this ended up delaying our decision to replace the GUI framework for over a week, which eventually pushed back the overall schedule. Such failures usually result in criticism of wasted time, even if it was unintentional.

But rather, our team said, <q>We found this choice to be wrong. We gained something.</q> We focused on not making this decision in the future. We reached a conclusion to <q>get together more often to find overlooked problems we could miss while focusing on solving issues.</q> As a concrete solution, we decided to create a mini-update session in the evening besides our daily meetings.

Through these mini sessions, we found out that our team often held onto same issues from the morning despite feeling that progress was going smoothly. This was a great feedback for us.

I really enjoyed our team’s <q>let’s try another way</q> as opposed to <q>why didn’t you do as we planned</q> mentality when things didn’t go as we expected.

Other Perks
--------
Planetarium has lots of perks, but these below are the most memorable:

- Remote Work Schedule
- Completely Horizontal Decision Making (true story)
- Accomplished & Capable Members

Closing
-------
While writing this piece, someone made this comment during our engineering workshop.

> We named our blog “Snack”, and yet we’ve been serving “main dishes” to our readers. (LOL)

So true. For this piece, I’ve cut down on words and tried putting in lots of screen shots for better experience. Hope this makes it more enjoyable. 

Finally, our team is always open to your contributions to [Libplanet]! If you are interested in our open-source project, we welcome you to hang out in our [discord channel]. Thanks everyone!

[discord channel]: https://discord.gg/planetarium
