---
layout: base.njk
---

# ARCS Lab

<img style="float:right; width:30%; margin-left: 1rem;" src="{{ "/static/img/arcs-lab-logo.png" | url }}" alt="ARCS Lab Logo">

The ARCS (**A**utonomous **R**obotics and **C**omplex **S**ystems) Lab is concerned with improving the robustness and adaptability of autonomous robots. We employ a variety of techniques to optimize small (on the scale of 30 centimeters) robotic systems that are able to navigate unpredictable and dynamic terrain while at the same time being adaptive with respect to potential damage. See [our Publications]({{ "/cv/#publications" | url }}) for more details.

## Members

### Graduate Students

- Rafail Islam (CS), Aug 2019
- Jesse Simpson (CS), Jan 2019 - Sep 2019
- Dipto Das (CS), Jan 2018 - Jul 2019 (**Thesis:** [A Multimodal Approach to Sarcasm Detection on Social Media](https://bearworks.missouristate.edu/theses/3417/))
- Keith Cissell (CS), Nov 2016 - Dec 2018 (**Thesis:** [An Adaptive Memory-Based Reinforcement Learning Controller](https://bearworks.missouristate.edu/theses/3326/))

### Undergraduates Students

<!-- Seth and Kimmy -->

- Ali Karimiafshar (MET), Sep 2019
- Drew Rinker (CS), May 2019
- William Fry (CS), May 2019
- Lauren Tallerico (CS), May 2019 - Dec 2019
- Normany Bryson (CS), May 2019 - Dec 2019
- Anna Buckthorpe (EE), Jan 2019 - May 2019
- Dillon Flohr (CS), Nov 2016 - Dec 2018
- Eric McCullough (CS), Aug - Dec 2018
- Rich Russell (CS), Sep 2017 - Dec 2018
- Dersham Schmidt (EE and Physics), Nov 2016 - May 2018
- Ryan DeLap (CS), Jun - May 2018
- Nick Hafner (CS), Summer 2018
- Daniel Warken (EE and Physics), Jul 2016 - Jul 2017
- Tyler Medlin (CS), Jan - Jul 2017
- Matthew Ridenhour (CS), Nov 2016 - Jul 2017

---

## Adabot

Our current project is to model, simulate, optimize, and fabricate a robot called the **Adabot**. You can find code for simulating the Adabot at [it's Github Repository](https://github.com/anthonyjclark/adabot) and the [paper can be found here on my CV]({{ "/cv/#Clark.2017.SSCI.EvolvingAdabotMobile" | url }}). The visualization below shows the basic idea behind the Adabot.

## Visualizer

<iframe src="https://review.github.io/?log=https://raw.githubusercontent.com/anthonyjclark/adabot02-ann/master/animations/fsm-40-2-best20.json" title="Review" width="80%" height="400" style="display: block; margin: 0 auto;">
  <p>Visualization not shown because your browswer does not support iframes.</p>
  <img src="{{ "/static/img/gz_step-wegs-out.png" | url }}" alt="Adabot Climbing a Step">
</iframe>

As a side project, we have been working on a simple method for sharing simulation results with collaborators around the world. What we want, in essence, is something akin to an on-line video player, but with the ability to view the simulation from different angles. My colleague and I started on this project a few years ago, but we never had a polished product ([you can see Dr. Jared Moore's version here](http://jaredmmoore.com/WebGL_Visualizer/visualizer.html)).

During the fall 2017 semester at Missouri State University, I gave the project over to a group of students in [CSE 450](https://computerscience.missouristate.edu/coursesoffered.htm#CSC450). The visualizer above was created with some of the concepts and ideas that they implemented.

You can learn more about this work be [reading our workshop paper]({{ "/cv#Clark.2018.GECCO.ReviewWebbasedSimulation" | url }}).
