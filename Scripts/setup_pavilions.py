import os
from typing import Any

from AoE2ScenarioParser.datasets.players import PlayerColorId, PlayerId
from AoE2ScenarioParser.datasets.buildings import BuildingInfo
from AoE2ScenarioParser.objects.data_objects.trigger import Trigger
from AoE2ScenarioParser.objects.data_objects.unit import Unit
from AoE2ScenarioParser.scenarios.aoe2_de_scenario import AoE2DEScenario, TriggerManager, UnitManager

# The path to your scenario folder

# The scenario object.
scenario: AoE2DEScenario = AoE2DEScenario.from_file(os.getcwd() + "/age 2 files/resources/_common/scenario/" + "AP_Attila_1.aoe2scenario")

class APavilionMaker():
    trigger_manager: TriggerManager
    unit_manager: UnitManager
    apavilion: Unit
    
    def __init__(self, scenario: AoE2DEScenario):
        self.trigger_manager = scenario.trigger_manager
        self.unit_manager = scenario.unit_manager
        self.apavilion = None

    def addPavilion(self):
        if not any(trigger.name == "-- APavilion --" for trigger in self.trigger_manager.triggers):
            self.trigger_manager.add_trigger("-- APavilion --")
            
        pavilion_space = self.unit_manager.get_units_in_area(x1=105, y1=4, x2=106, y2=5)
        if len(pavilion_space) == 0:
            self.apavilion = self.unit_manager.add_unit(
                player = PlayerId.ONE,
                unit_const = BuildingInfo.PAVILION_A,
                x=105.0,
                y=4.0
            )
        else:
            self.apavilion = pavilion_space[0]
        
        first_trigger_id = self._add_color_rotation(PlayerColorId.RED, "Red", 1)
        self._add_color_rotation(PlayerColorId.GREEN, "Green")
        self._add_color_rotation(PlayerColorId.PURPLE, "Purple")
        self._add_color_rotation(PlayerColorId.ORANGE, "Orange")
        self._add_color_rotation(PlayerColorId.BLUE, "Blue")
        self._add_color_rotation(PlayerColorId.YELLOW, "Yellow", trigger_id=first_trigger_id)
        
        if not any(trigger.name == "APavilion Victory Tech" for trigger in self.trigger_manager.triggers):
            ap_victory_tech = self.trigger_manager.add_trigger("APavilion Victory Tech")
            
            ap_victory_tech.new_effect.change_technology_name(1, 1180, message="Declare Victory")



    def _add_color_rotation(self, color: PlayerColorId, color_name: str, timer: int = 2, trigger_id: int = None) -> int:
        color_trigger: Trigger = None
        for trigger in self.trigger_manager.triggers:
            if trigger.name == f"APavilion {color_name}":
                color_trigger = trigger
                break
        
        if color_trigger == None:
            color_trigger = self.trigger_manager.add_trigger(f"APavilion {color_name}")
    
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

pavilion = APavilionMaker(scenario)
pavilion.addPavilion()

scenario.write_to_file("AP_Attila_1.aoe2scenario")