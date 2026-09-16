import os
from typing import Any

from AoE2ScenarioParser.datasets.players import PlayerColorId, PlayerId
from AoE2ScenarioParser.datasets.buildings import BuildingInfo
from AoE2ScenarioParser.datasets.effects import EffectId
from AoE2ScenarioParser.datasets.trigger_lists import Operation
from AoE2ScenarioParser.objects.data_objects.trigger import Trigger
from AoE2ScenarioParser.objects.data_objects.unit import Unit
from AoE2ScenarioParser.scenarios.aoe2_de_scenario import AoE2DEScenario, TriggerManager, UnitManager

# The path to your scenario folder

# The scenario object.

# Dropping the HP this far and then adding zero leaves the pavilion on 0 HP, which the engine
# treats as indestructible. Both effects are needed; the drop alone does not do it.
INDESTRUCTIBLE_HP_DROP = -500

# The technology the player researches in the pavilion to end the scenario.
VICTORY_TECHNOLOGY = 1180

class APavilionMaker():
    trigger_manager: TriggerManager
    unit_manager: UnitManager
    apavilion: Unit
    x: int
    y: int
    
    _color_trigger_id: int
    
    def __init__(self, scenario: AoE2DEScenario, x: int, y: int):
        self.trigger_manager = scenario.trigger_manager
        self.unit_manager = scenario.unit_manager
        self.apavilion = None
        self.x = x
        self.y = y

    def add_pavilion(self):
        if not any(trigger.name == "-- APavilion --" for trigger in self.trigger_manager.triggers):
            self.trigger_manager.add_trigger("-- APavilion --")
            
        pavilion_space = self.unit_manager.get_units_in_area(x1=self.x - 1, y1=self.y - 1, x2=self.x, y2=self.y)
        if len(pavilion_space) == 0:
            self.apavilion = self.unit_manager.add_unit(
                player = PlayerId.ONE,
                unit_const = BuildingInfo.PAVILION_A.ID,
                x=self.x,
                y=self.y
            )
        else:
            self.apavilion = pavilion_space[0]
        
        self._color_trigger_id = self._add_color_rotation(PlayerColorId.RED, "Red", 1)
        self._add_color_rotation(PlayerColorId.GREEN, "Green")
        self._add_color_rotation(PlayerColorId.PURPLE, "Purple")
        self._add_color_rotation(PlayerColorId.ORANGE, "Orange")
        self._add_color_rotation(PlayerColorId.BLUE, "Blue")
        self._add_color_rotation(PlayerColorId.YELLOW, "Yellow", trigger_id=self._color_trigger_id)
        
        self._add_startup()

    def _add_startup(self) -> None:
        pavilion_startup: Trigger = None
        for trigger in self.trigger_manager.triggers:
            if trigger.name == "APavilion Startup":
                pavilion_startup = trigger
                break
        
        if pavilion_startup == None:
            pavilion_startup = self.trigger_manager.add_trigger("APavilion Startup")

        # Name
        if not any(effect.effect_type == EffectId.CHANGE_OBJECT_NAME
                   for effect in pavilion_startup.effects):
            pavilion_startup.new_effect.change_object_name(selected_object_ids=[self.apavilion.reference_id], message="AP-vilion")

        #Technology name
        if not any(effect.effect_type == EffectId.CHANGE_TECHNOLOGY_NAME
                   and effect.technology == VICTORY_TECHNOLOGY
                   for effect in pavilion_startup.effects):
            pavilion_startup.new_effect.change_technology_name(1, VICTORY_TECHNOLOGY, message="Declare Victory")

        # Can't delete
        if not any(effect.effect_type == EffectId.DISABLE_OBJECT_DELETION
                   for effect in pavilion_startup.effects):
            pavilion_startup.new_effect.disable_object_deletion(
                source_player=PlayerId.ONE,
                selected_object_ids=[self.apavilion.reference_id]
            )
        
        # Indestructible, two effects: 1. -500 HP, 2. add 0 HP
        for quantity in (INDESTRUCTIBLE_HP_DROP, 0):
            if any(effect.effect_type == EffectId.CHANGE_OBJECT_HP
                   and effect.operation == Operation.ADD
                   and effect.quantity == quantity
                   for effect in pavilion_startup.effects):
                continue
            
            pavilion_startup.new_effect.change_object_hp(
                quantity=quantity,
                operation=Operation.ADD,
                source_player=PlayerId.ONE,
                selected_object_ids=[self.apavilion.reference_id]
            )

    def add_victory_triggers(self) -> None:
        if self.apavilion == None:
            raise ValueError("Pavilion not found. Run add_pavilion first.")
        victory: Trigger = None
        
        for trigger in self.trigger_manager.triggers:
            if trigger.name == f"AP Has Victory":
                self.trigger_manager.remove_trigger(trigger.trigger_id)
                break
        
        victory = self.trigger_manager.add_trigger("AP Has Victory")
    
        victory.new_condition.script_call("HasVictory();")
        
        victory.new_effect.change_view(
            location_x=self.x,
            location_y=self.y
        )
        
        victory.new_effect.change_ownership(
            source_player=PlayerId.ONE,
            target_player=PlayerId.ONE,
            flash_object=1,
            selected_object_ids=[self.apavilion.reference_id]
        )
        
        victory.new_effect.display_instructions(
            source_player=PlayerId.ONE,
            message="Click \"Victory\" in the APavilion to win or keep playing for checks."
        )
        
        victory.new_effect.activate_trigger(self._color_trigger_id)
        
        victory.new_effect.script_call(message="ShowVictory();")
        
        for trigger in self.trigger_manager.triggers:
            if trigger.name == f"AP Declare Victory":
                self.trigger_manager.remove_trigger(trigger.trigger_id)
                break
            
        declare_victory: Trigger = self.trigger_manager.add_trigger("AP Declare Victory")
        
        declare_victory.new_condition.technology_state(technology=VICTORY_TECHNOLOGY, quantity=3, source_player=1)
        
        declare_victory.new_effect.declare_victory(source_player=1)

    def _add_color_rotation(self, color: PlayerColorId, color_name: str, timer: int = 2, trigger_id: int = None) -> int:
        color_trigger: Trigger = None
        for trigger in self.trigger_manager.triggers:
            if trigger.name == f"APavilion {color_name}":
                color_trigger = trigger
                break
        
        if color_trigger == None:
            color_trigger = self.trigger_manager.add_trigger(f"APavilion {color_name}")
    
            color_trigger.enabled = 0
            color_trigger.new_condition.timer(timer)
        
            color_trigger.new_effect.change_object_player_color(
                source_player=PlayerId.ONE,
                player_color=color,
                selected_object_ids=[self.apavilion.reference_id]
            )
            
            if trigger_id == None:
                trigger_id = color_trigger.trigger_id + 1
            
            color_trigger.new_effect.activate_trigger(
                trigger_id=trigger_id
            )
        
        return color_trigger.trigger_id
