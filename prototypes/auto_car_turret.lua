



data:extend(
{
  {
    type = "turret",
    name = "turret_auto_car",
    icon = "__base__/graphics/icons/medium-worm.png",
    flags = {"placeable-player", "placeable-enemy", "not-repairable", "breaths-air"},
    order="b-b-e",
    subgroup="enemies",
    max_health = 800,
    resistances =
    {
      {
        type = "physical",
        decrease = 40,
      },
      {
        type = "explosion",
        decrease = 40,
        percent = 15,
      }
    },
	call_for_help_radius = 25,
    healing_per_tick = 0.0015,
    collision_box = {{-1.1, -1.0}, {1.1, 1.0}},
	collision_mask = {},
    selection_box = {{-1.1, -1.0}, {1.1, 1.0}},
    shooting_cursor_size = 3.5,
    rotation_speed = 0.015,
    corpse = "medium-worm-corpse",
    dying_explosion = "blood-explosion-big",
    dying_sound = make_worm_dying_sounds(0.9),
    folded_speed = 0.01,
    folded_animation =
    {
      layers =
      {
        laser_turret_extension{frame_count=1, line_length = 1},
        laser_turret_extension_shadow{frame_count=1, line_length=1},
        laser_turret_extension_mask{frame_count=1, line_length=1}
      }
    },
    prepare_range = 25,
    preparing_speed = 0.025,
    preparing_animation =
    {
      layers =
      {
        laser_turret_extension{},
        laser_turret_extension_shadow{},
        laser_turret_extension_mask{}
      }
    },
    prepared_speed = 0.015,
    prepared_animation =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/laser-turret/laser-turret-gun.png",
          line_length = 8,
          width = 68,
          height = 68,
          frame_count = 1,
          axially_symmetrical = false,
          direction_count = 64,
          shift = {0.0625, -1}
        },
        {
          filename = "__base__/graphics/entity/laser-turret/laser-turret-gun-mask.png",
          line_length = 8,
          width = 54,
          height = 44,
          frame_count = 1,
          axially_symmetrical = false,
          apply_runtime_tint = true,
          direction_count = 64,
          shift = {0.0625, -1.3125},
        },
        {
          filename = "__base__/graphics/entity/laser-turret/laser-turret-gun-shadow.png",
          line_length = 8,
          width = 88,
          height = 52,
          frame_count = 1,
          axially_symmetrical = false,
          direction_count = 64,
          draw_as_shadow = true,
          shift = {1.59375, 0}
        }
      }
    },
    --starting_attack_speed = 0.03,
    --starting_attack_animation = worm_attack_animation(medium_worm_scale, medium_worm_tint, "forward"),
    --starting_attack_sound = make_worm_roars(0.8),
    --ending_attack_speed = 0.03,
    --ending_attack_animation = worm_attack_animation(medium_worm_scale, medium_worm_tint, "backward"),
    folding_speed = 0.015,
    folding_animation =
    {
      layers =
      {
        laser_turret_extension{run_mode = "backward"},
        laser_turret_extension_shadow{run_mode = "backward"},
        laser_turret_extension_mask{run_mode = "backward"}
      }
    },
    prepare_range = 30,
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "rocket",
      cooldown = 10,
      range = 17,
      projectile_creation_distance = 1.9,
      damage_modifier = 3,
      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
            {
              {
                type = "projectile",
                projectile = "laser",
                starting_speed = 0.28
              }
            }
        }
      }
    },
  },
})