---
layout: post
title: "7DRL 2012 - Day 0: Introducing MechRL"
date: 2012-03-10 22:37
comments: true
categories: 
- 7DRL
---
Although I didn't have that much time lately, I came up with an idea that is worth prototyping in a 7DRL. I was a huge fan of the MechWarrior franchise back in the late 90s and early 2000s. After watching the [Hawken Gameplay Video](http://www.youtube.com/watch?v=udEAEARD-Fo) some time ago, I got a bit nostalgic and thought about doing a *MechWarriorlike Roguelike*. Through the lack of a better name (naming things is hard!), I'll simply call it MechRL.

<!--more-->

## Mechanics
The movement of the mechs in MechWarrior was similar to that of a car in racing game. You had to accelerate/decelerate your mech and you weren't able to change directions immediately but you rather had to turn. The movement paramters like v_max and inertia where also influenced by the weight of the mech.

Another interesting mechanic was the combat which was closely related to movement. You were only able to shoot in the direction your mech was facing. Some mechs were able to turn their torso seperately from their legs which allowed you to perform some neat run-by attacks.

Those two mechanics embody the core mechanics for my roguelike. It will be quite interesesting to
see how these mechanics work in a turn-based environment. In case it won't work well, I might try a
hybrid approach instead of a turn-based one. The actual combat won't also be skill shot based like in
MechWarrior but something like VATS in Fallout 3.

## Dungeon Design
The usual dungeon crawler'ish design for a roguelike won't really work for MechRL. Instead, I opt
for a non-linear mission design which drives a very simple story. I have about 7-10 missions planned
  currently. Most of the missions will all take place on the same map whose layout will be randomly
  generated. There will also be some kind of outpost which serves as the mission hub and a place to customize/upgrade your mech.

## Character Progress
That brings me to the progression of your mech throughout the game. In the beginning, you will choose one of
~three starter mechs that differ in their playstyle (fast and agil, slow and heavy
armed,...). You will then be able to update the weapons and armor with stuff you find or completely
replace parts of the mech. There won't be alot of <strike>character</strike>mech stats but each part
of your mech will have its own durability.

## User Interface
As for the UI, although the game won't run in a console, I will likely stick to ASCII art most of
the time. I'm not that at graphic design and it simply costs to much time that I won't have. I'll
also focus on keyboard input first and only add mouse support if I have some time left.
