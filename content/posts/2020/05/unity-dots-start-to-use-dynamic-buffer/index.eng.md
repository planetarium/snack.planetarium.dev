---
title: How to Use Unity DOTS DynamicBuffer
date: 2020-05-18
authors: [hyun.seungmin]
translators: [kidon.seo]
---

Hello, I'm Hyun Seungmin, [Nine Chronicles] developer at [Planetarium]. Our project is not yet using Unity [<abbr title="Data-Oriented Technology Stack">DOTS</abbr>][DOTS] but we are working hard to apply it to our next project. So from now on, I will be sharing what I've learned in my studies.

This time, let's have a look at [`DynamicBuffer<T>`][DynamicBuffer<T>]. We’re going to talk about setting up a dynamic buffer on an entity and using it. Although we’re starting  a few steps ahead for our very first DOTS article, I think you can catch on right away by following this piece because the skipped portion isn’t that substantial.

This article refers to the [Unity Official Docs] and the [tutorial video].


[Planetarium]: https://planetariumhq.com/
[Nine Chronicles]: https://nine-chronicles.com/
[DOTS]: https://unity.com/dots
[DynamicBuffer<T>]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.DynamicBuffer-1.html
[Unity Official Docs]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/manual/dynamic_buffers.html
[tutorial video]: https://www.youtube.com/watch?v=XC84bc95heI


## Dev Environment

Unity
:  2019.3.12f1

`com.unity.entities`
:  0.10.0-preview.6


## [`IBufferElementData`][IBufferElementData] Implementation


Just as components that are added to an entity must implement the [`IComponentData` Interface][IComponentData], `DynamicBuffer<T>` must also implement the [`IBufferElementData` Interface][IBufferElementData].

 -  I’ve created an `IntBufferElement` structure that implements `IBufferElementData`. It’s format is similar to `IComponentData`, right?


    ~~~~ cs
    using Unity.Entities;

    namespace DOTS_DynamicBuffer
    {
      public struct IntBufferElement : IBufferElementData
      {
        public int Value;
      }
    }
    ~~~~

[IComponentData]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.IComponentData.html
[IBufferElementData]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.IBufferElementData.html


## Using [`EntityManager.AddBuffer<T>()`][EntityManager.AddBuffer<T>()] 


Just like adding a component to an entity, we need to use [`EntityManager`][EntityManager] when adding buffers. Below, I’ve written a component called `PlayModeTest` that will be added to game objects and with that, let’s check the *Entity Debugger* in play mode.


 -  Let’s add an `IntBufferElement` buffer to the entity and put some values in it.


    ~~~~ cs
    using UnityEngine;
    using Unity.Entities;

    namespace DOTS_DynamicBuffer
    {
      public class PlayModeTest : MonoBehaviour
      {
        private void Awake()
        {
          var entityManager = World.DefaultGameObjectInjectionWorld.EntityManager;
          var entity = entityManager.CreateEntity();
          var dynamicBuffer = entityManager.AddBuffer<IntBufferElement>(entity);
          dynamicBuffer.Add(new IntBufferElement { Value = 1 });
          dynamicBuffer.Add(new IntBufferElement { Value = 2 });
          dynamicBuffer.Add(new IntBufferElement { Value = 3 });
        }
      }
    }
    ~~~~

 -  I’ve created *DOTS_DynamicBufferScene* and added the `PlayModeTest` script to a game object with the same name.


    ![](images/01.png)

 -  In play mode, you can check the entity created by the `PlayModeTest.Awake()` method through _Entity Debugger_. Can you see that the `IntBufferElement` buffer has three values?


    ![](images/02.png)

[EntityManager.AddBuffer<T>()]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.EntityManager.html#Unity_Entities_EntityManager_AddBuffer__1_Unity_Entities_Entity_
[EntityManager]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.EntityManager.html


## Using [`DynamicBuffer<T>.Reinterpret<U>()`][DynamicBuffer<T>.Reinterpret<U>()] 

Now let's find out how to modify the values contained in the structure of the buffer.


 -  I’ve used [`DynamicBuffer<T>.Reinterpret<U>()` Method][DynamicBuffer<T>.Reinterpret<U>()], which is a minor modification of `PlayModeTest.Awake()`. And as shown on line 12, structure that’s accessed with index values cannot be changed because it is a temporary value that is not classified as a variable. However, the values can be modified using the reinterpret method as you can see on line 14--15.


    ~~~~ cs
    private void Awake()
    {
        var entityManager = World.DefaultGameObjectInjectionWorld.EntityManager;
        var entity = entityManager.CreateEntity();
        var dynamicBuffer = entityManager.AddBuffer<IntBufferElement>(entity);
        dynamicBuffer.Add(new IntBufferElement {Value = 1});
        dynamicBuffer.Add(new IntBufferElement {Value = 2});
        dynamicBuffer.Add(new IntBufferElement {Value = 3});

        // ERROR: Indexer access returns temporary value.
        // Cannot modify struct member when accessed struct is not classified as a variable
        // dynamicBuffer[0].Value *= 10;

        var intDynamicBuffer = dynamicBuffer.Reinterpret<int>();
        intDynamicBuffer[0] *= 10;
    }
    ~~~~

 -  Let’s check the play mode to see if the value has changed. Great! So our takeaway is that the buffer’s value changed despite not putting in the value of `intDynamicBuffer[0]`back into `dynamicBuffer[0]`.


    ![](images/03.png)

[DynamicBuffer<T>.Reinterpret<U>()]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.DynamicBuffer-1.html#Unity_Entities_DynamicBuffer_1_Reinterpret__1


## Using [`EntityManager.GetBuffer<T>()`][EntityManager.GetBuffer<T>()] 

We also need a way to access the buffer on the entity.


 -  I’ve modified the `PlayModeTest` class. And I’ve changed the value by importing the entity generated by the `Awake()` method and the buffer added to it using the `Start()` method.


    ~~~~ cs
    public class PlayModeTest : MonoBehaviour
    {
      private Entity _entity;

      private void Awake()
      {
        var entityManager = World.DefaultGameObjectInjectionWorld.EntityManager;
        _entity = entityManager.CreateEntity();

        var dynamicBuffer = entityManager.AddBuffer<IntBufferElement>(_entity);
        dynamicBuffer.Add(new IntBufferElement { Value = 1 });
        dynamicBuffer.Add(new IntBufferElement { Value = 2 });
        dynamicBuffer.Add(new IntBufferElement { Value = 3 });

        // ERROR: Indexer access returns temporary value.
        // Cannot modify struct member when accessed struct is not classified as a variable
        // dynamicBuffer[0].Value *= 10;
        var intDynamicBuffer = dynamicBuffer.Reinterpret<int>();
        intDynamicBuffer[0] *= 10;
      }

      private void Start()
      {
        var entityManger = World.DefaultGameObjectInjectionWorld.EntityManager;
        var dynamicBuffer = entityManger.GetBuffer<IntBufferElement>(_entity);
        var intDynamicBuffer = dynamicBuffer.Reinterpret<int>();
        for (var i = 0; i < intDynamicBuffer.Length; i++)
        {
          intDynamicBuffer[i]++;
        }
      }
    }
    ~~~~

 -  Let’s check if it works well. All values in the buffer have increased by one! `Reinterpret<T>()` is fascinating.


    ![](images/04.png)

[EntityManager.GetBuffer<T>()]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.EntityManager.html#Unity_Entities_EntityManager_GetBuffer__1_Unity_Entities_Entity_


## Authoring

[`GenerateAuthoringComponentAttribute`][GenerateAuthoringComponentAttribute] allows you to add Authoring Component to a game object to make an entity. `IBufferElementData` can use the same method.


 -  Let’s modify `IntBufferElement` and apply `GenerateAuthoringComponentAttribute`.


    ~~~~ cs
    [GenerateAuthoringComponent]
    public struct IntBufferElement : IBufferElementData
    {
      public int Value;
    }
    ~~~~

 -  And I’ve added `IntBufferElementAuthoring` component that was automatically generated by modifying Scene and added value to the game object. I’ve also added `ConvertToEntity` component to make the game object into an entity.


    ![](images/05.png)

 -  The *Entity Debugger* shows that an entity with the same name is created as a game object with **Authoring** components.


    ![](images/06.png)

 -  For our next step, let’s write `UnitTag`, `PlayerTag` and `EnemyTag` components and add an `IntBufferElement` buffer to the entity that includes each component.


    ~~~~ cs
    using Unity.Entities;

    namespace DOTS_DynamicBuffer
    {
      [GenerateAuthoringComponent]
      public struct UnitTag : IComponentData { }

      [GenerateAuthoringComponent]
      public struct PlayerTag : IComponentData { }

      [GenerateAuthoringComponent]
      public struct EnemyTag : IComponentData { }
    }
    ~~~~

    ![](images/07.png)

    ![](images/08.png)

[GenerateAuthoringComponentAttribute]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.GenerateAuthoringComponentAttribute.html


## Using the `DynamicBuffer` in `ComponentSystem`

Now, let’s access the entity’s `IntBufferElement` `DynamicBuffer` that includes the `UnitTag` component by creating a system that inherits `ComponentSystem`.


 -  I’ve written a `TestBufferFromEntitySystem`. This logic changes the value by accessing an entity’s `IntBufferElement`type `DynamicBuffer` that includes `UnitTag`. Implementing this like on line 20 doesn’t work, so refer to line 23--28. And of course, we can also use `Reinterpret<T>()`.


    ~~~~ cs
    using Unity.Entities;

    namespace DOTS_DynamicBuffer
    {
      public class TestBufferFromEntitySystem : ComponentSystem
      {
        protected override void OnUpdate()
        {
          var bufferFromEntity = GetBufferFromEntity<IntBufferElement>();
          Entities
            .WithAll<UnitTag>()
            .ForEach(entity =>
            {
              if (bufferFromEntity.Exists(entity))
              {
                var dynamicBufferFromUnitTag = bufferFromEntity[entity];
                foreach (var intBufferElement in dynamicBufferFromUnitTag)
                {
                  // Foreach iteration variable 'intBufferElement' is immutable.
                  // Cannot modify struct member when accessed struct is not classified as a variable
                  // intBufferElement.Value++;
                }

                for (var i = 0; i < dynamicBufferFromUnitTag.Length; i++)
                {
                  var intBufferElement = dynamicBufferFromUnitTag[i];
                  intBufferElement.Value++;
                  dynamicBufferFromUnitTag[i] = intBufferElement;
                }
              }
            });
        }
      }
    }
    ~~~~

 -  If you look at *Entity Debugger* in play mode, you can see that the value of `UnitTag` component including entity's `IntBufferElement` `DynamicBuffer` changes.


    ![](images/09.png)


## Using the `DynamicBuffer` in `JobComponentSystem`

Let’s create a system that inherits `JobComponentSystem` and try to access `IntBufferElement` `DynamicBuffer` of an entity that includes the `PlayerTag` component.


 -  I’ve written a `TestBufferFromEntityJobSystem`. This logic changes the value by accessing `IntBufferElement` type `DynamicBuffer` of entities that include `PlayerTag`. This time I tried `Reinterpret<T>()`.


    ~~~~ cs
    using Unity.Entities;
    using Unity.Jobs;

    namespace DOTS_DynamicBuffer
    {
      public class TestBufferFromEntityJobSystem : JobComponentSystem
      {
        protected override JobHandle OnUpdate(JobHandle inputDeps)
        {
          return Entities
            .WithAll<PlayerTag>()
            .ForEach((ref DynamicBuffer<IntBufferElement> dynamicBuffer) =>
            {
              var intDynamicBuffer = dynamicBuffer.Reinterpret<int>();
              for (var i = 0; i < intDynamicBuffer.Length; i++)
              {
                intDynamicBuffer[i]++;
              }
            })
            .Schedule(inputDeps);
        }
      }
    }
    ~~~~

 -  It's working! The value is increasing just like we wanted.


    ![](images/10.png)


## Additional Tips

### [`InternalBufferCapacityAttribute`][InternalBufferCapacityAttribute]

Since entities are generally included in chunks, applying `InternalBufferCapacityAttribute` to a structure that implements `IBufferElementData` can specify the maximum number of elements that can exist in chunks. When the elements go over the specified limit, the buffer movers over to the heap memory. Of course, you can access the buffer through `DynamicBuffer` API as well.


 -  Here, I've set the number of elements to two.


    ~~~~ cs
    // InternalBufferCapacity specifies how many elements a buffer can have before
    // the buffer storage is moved outside the chunk.
    [InternalBufferCapacity(2)]
    [GenerateAuthoringComponent]
    public struct IntBufferElement : IBufferElementData
    {
      public int Value;
    }
    ~~~~

 -  And to hold tests in the same chunk, I’ve copied two more Enemy game objects that includes `EnemyTag`.


    ![](images/11.png)

 -  Let’s check the *Entity Debugger*. But it looks like `IntBufferElement` is still in the chunk. This may be for convenience even though the buffer has been moved to the heap memory. 


    ![](images/12.png)

[InternalBufferCapacityAttribute]: https://docs.unity3d.com/Packages/com.unity.entities@0.10/api/Unity.Entities.InternalBufferCapacityAttribute.html


### `implicit` Operator

We can also write our code this way for convenience.


~~~~ cs
using Unity.Entities;

namespace DOTS_DynamicBuffer
{
  // InternalBufferCapacity specifies how many elements a buffer can have before
  // the buffer storage is moved outside the chunk.
  [InternalBufferCapacity(2)]
  [GenerateAuthoringComponent]
  public struct IntBufferElement : IBufferElementData
  {
    public int Value;

    // The following implicit conversions are optional, but can be convenient.
    public static implicit operator int(IntBufferElement e)

    {
      return e.Value;
    }

    public static implicit operator IntBufferElement(int e)

    {
      return new IntBufferElement { Value = e };
    }
  }
}
~~~~

## Closing

Today, we took a quick look at `IBufferElementData` and DynamicBuffer<T>`.

You've probably heard a lot about object pooling when you’re making games.  Since creating single-use objects is basically the same as creating garbage, pooling and reusing them can reduce frequent [garbage collection] and manage instance creation timing, which ultimately creates a smoother game.

Next time, let's find out how to apply this feature and compare the before and after to see how much improvement you can get.


[garbage collection]: https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)
