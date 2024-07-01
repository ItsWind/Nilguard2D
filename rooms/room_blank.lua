local roomData = {}
roomData.name = "blank"
roomData.nextRoomName = "nil"
roomData.playerX = 0
roomData.playerY = 0
roomData.ambientLight = {0.5, 0.5, 0.5}
roomData.ambientOutside = false
roomData.musicName = "FFXAttack"
roomData.outsideLights = {
}
roomData.navPolygons = {
    {
        }
}
roomData.gameObjects = {
    }
roomData.tiles = {
    }
function GetRoomData()
    return roomData
end
return {GetRoomData = GetRoomData}