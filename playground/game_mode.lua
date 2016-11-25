local GameMode = extends_keep_existing (game_manager.gameModes['Playground'], ThirdPersonGameMode) {
    name = 'Playground',
    description = 'Open World Game Demo',
    previewImage = `GameMode.png`,
    map = `map.gmap`,
    spawnPos = vec(-53.45975, 9.918219, 1.112),
    spawnRot = quat(-0.3363351, 0, 0, 0.9417424),

    seaLevel = -6,
}

function GameMode:init()

    ThirdPersonGameMode.init(self)

    self.protagonist = object `/detached/characters/robot_scout` (0, 0, 0) { }
    self.vehicle = nil

    object `/vehicles/Scarman` (-49.45975, 9.918219, 1.112) { }

    object `pickup_gearUpgradeTree1` (-49.45975, 5.918219, 1.112) { }
    object `pickup_energyReplenish` (-44.45975, 5.918219, 1.112) { }
    object `pickup_tool_ioWire` (-39.45975, 5.918219, 1.112) { }
    object `pickup_lesserGearBundle` (-34.45975, 5.918219, 1.112) { }

    self.coinsPickedUp = 0
    self.coinsTotal = 1

    self:playerRespawn()
end

function GameMode:coinPickUp()
    self.coinsPickedUp = self.coinsPickedUp + 1
end

game_manager:register(GameMode)
