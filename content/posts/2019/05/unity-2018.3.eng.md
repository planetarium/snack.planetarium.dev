---
title: " Migrating from Unity 2018.2 to 2018.3"
date: 2019-05-17
authors: [hyun.seungmin]
translators: [kidon.seo]
---

Hello, I'm Seungmin Hyun from Planetarium Game-Dev Team. We’ve been preparing a migration to utilize some of the features added or improved on Unity 2018.3.

Nested Prefab
-------------

There have already been numerous references on the improved workflow thanks to Nested Prefab.

Simultaneous Editing
:   Previously, teams had to talk prior to fixing each prefab. Otherwise, prefabs fixed by different members from their local storage were bound to crash when uploaded in the upstream storage. However, the new prefab has a way to avoid this conflict by structuring the change points into separate prefabs. Although there is still room for collision between the same prefab, the frequency has significantly decreased due to the smaller category of prefab.

Multiple Structure
:   Whereas one prefab was traditionally a single structure that contained all of the objects under it, the new prefab can separate the specific objects under it into another prefab, and the objects under the prefab can be multi-structured to be managed by that prefab. This method allows the prefab to be modularized and reusable, reducing redundancy.

Prefab Variant
:   You can create a prefab variant by inheriting one prefab while overriding its internal properties or adding components/game objects. This reduces the cost of managing the prefab because changes in the original prefab are reflected on the prefab variant.

Prefab Mode
:   Traditionally, creating or modifying a prefab required creating a temporary instance in the scene, modifying it, reflecting it in the prefab, and then erasing the temporary instance again. These required lots of tedious work and there were plenty of room for mistakes in each process. But the newly added prefab mode simplified these workflows to improve dev speed and reliability. Unfortunately, there are still bugs in the prefab mode such as graphic visibility issues, which requires the old way of modification.

Memory Profiler 
---------------

You can now use enhanced memory profilers to get a more detailed approach to troubleshooting.

2D Animation v2
---------------

The workflows of Unity’s traditional animation system were so uncomfortable that they needed to be migrated to either the new 2D Animation v2 or an external tool called Spine. Although we ended up using Spine, we were able to see great improvement in 2D Animation v2.

Particle System 
---------------

Because visual effects are extremely important in our project, we aimed for an overall enhancement through the newly improvement Particle System. Despite not making any modifications to the resource, we received positive feedback from our visual arts team on the evident enhancement of visual effects.

----

Unexpectedly, a day before our migration, Unity 2019.1 was officially released. So in the following article, we will look at the added features of Unity 2019.1 and talk about how we responded.
