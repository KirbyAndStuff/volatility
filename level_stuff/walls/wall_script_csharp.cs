using Godot;
using System;

public partial class WallScript : Node
{
	private Vector2 screenSize;
	private Particles2D particles;

	public override void _Ready()
	{
		screenSize = GetViewport().Size;
		Particles2D = GetNode<Particles2D>("res://level_stuff/walls/white_wall.tscn");
	}

	private void _on_hide_timeout()
	{
		Vector2 locationDif = GlobalPosition - GetNode<Position2D>("../../player").GlobalPosition;

		if (Math.Abs(locationDif.x) > (screenSize.x / 2) * 2 || Math.Abs(locationDif.y) > (screenSize.y / 2) * 2)
		{
			Hide();
			GetNode<StaticBody2D>("StaticBody2D/CollisionShape2D").Disabled = true;
			particles.Hide();
		}
		else
		{
			Show();
			GetNode<StaticBody2D>("StaticBody2D/CollisionShape2D").Disabled = false;
			particles.Show();
		}
	}
}
