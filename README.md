# Godot-Turn-Based-Battle-System-3D

Uses Godot 4.3. Written in GDScript.

# Dependency Notice

This project uses PhantomCamera, which can be downloaded from the Godot AssetLib or at its [GitHub](https://github.com/ramokz/phantom-camera).

# General Info

All battle scenes will inherit from the BattleBase scene, TestBattle being the scene to demonstrate battles.

The test scene is fully set up, and it is reccomended to use it as an example.

In the battle scene, put any player characters(Scenes that inherit from actor_3d) under Heroes, and enemies under Enemies(also inheriting from actor_3d). The BattleManager will automatically grab them and put them in appropriate arrays.

On the actors, via the inspector, you can set thier basic stats and general info.

If you have an enemy, make sure it has its own AI Script inheriting from AI_Base.gd, such as the AI_Sword_Enemy.gd script, and that you assign it to the actor script in the inspector.

# Credits

[Phantom Camera](https://github.com/ramokz/phantom-camera)
[Sprites for particle effects are provided from this video.](https://youtu.be/GeParYI2J6I)
