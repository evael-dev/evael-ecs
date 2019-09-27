module evael.ecs.system_manager;

import std.algorithm;

import evael.ecs.system;
import evael.ecs.entity;
import evael.containers.array;

class SystemManager
{
	private Array!System m_systems;

	@nogc
	public this()
	{
	}

	@nogc
	public ~this()
	{
		this.m_systems.dispose();
	}

	public void update(in float deltaTime)
	{
		// TODO: build a array with automatic update systems ?
		foreach (system; this.m_systems)
		{
			if (system.updatePolicy == System.UpdatePolicy.Automatic)
			{
				system.update(deltaTime);
			}
		}
	}

	@nogc
	public void add(System system)
	{
		this.m_systems.insert(system);
	}

	/**
	 * An entity has been activated.
	 * Params:
	 *      entity :
	 *      masks : entity's components masks
	 */
	public void onEntityActivated(ref Entity entity, bool[] masks)
	{
		foreach (system; this.m_systems)
		{
			if (this.systemComponentsFilterMatchesWithEntity(system, entity, masks))
			{
				system.onEntityActivated(entity);
			}
		}
	}

	/**
	 * An entity has been killed.
	 * Params:
	 *      entity :
	 *      masks : entity's components masks
	 */
	public void onEntityKilled(ref Entity entity, bool[] masks)
	{
		foreach (system; this.m_systems)
		{
			if (this.systemComponentsFilterMatchesWithEntity(system, entity, masks))
			{
				system.onEntityKilled(entity);
			}
		}
	}

	/**
	 * Triggers an event when a system components filter matches with an entity components mask.
	 * Params:
	 *		entity :
	 *		mask : entity's components masks
	 *		event : event to trigger
	 */
	@nogc
	private bool systemComponentsFilterMatchesWithEntity(System system, ref Entity entity, bool[] masks)
	{
		// componentsFilter contains all mandatory components ids for current system
		// We check if each component is known by the entity manager and if its in the
		// entity components mask
		auto componentsFilter = system.componentsFilter;
		
		if (componentsFilter.length && componentsFilter.all!(componentId => componentId < masks.length && masks[componentId]))
		{
			return true;
		}

		return false;
	}
}