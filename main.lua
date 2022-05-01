local screenW, screenH = guiGetScreenSize()

local ceil = math.ceil
local abs = math.abs

local map = dxCreateTexture('assets/images/map.png')
local screenSource = dxCreateScreenSource(screenW, screenH)

local factorScale = 6000 / config.sizeImage
local zoom = 1.2
local size = 60 / (4 - zoom) + 3
local alphaProgress = 0
local renderMinimap = false

local targetSize = ceil((config.panelWidth + config.panelHeight) * 0.85)
local renderTarget = dxCreateRenderTarget(targetSize, targetSize)

addEventHandler('onClientResourceStart', resourceRoot, function()
    swithDefaultHud(false)
    toggleMinimap(true)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    swithDefaultHud(true)
    toggleMinimap(false)
end)

function remapFirst(pos)
    return (- pos + 3000) / factorScale
end

function remapSecond(pos)
    return (pos + 3000) / factorScale
end

function renderBlip(icon, blipX, blipY, middleX, middleY, width, height, color, rotZ)
    local posX = 0 + targetSize / 2 + (remapFirst(middleX) - remapFirst(blipX)) * zoom
    local posY = 0 + targetSize / 2 - (remapFirst(middleY) - remapFirst(blipY)) * zoom

    if (config.renderBlips) then
        dxDrawImage(posX - width / 2, posY - height / 2, width, height, 'assets/images/blips/'..icon..'.png', 360 - rotZ, 0, 0, color)
    end
end

function minimap()
    if (not renderMinimap) then
        return
    end

    local gPosX, gPosY = 30, screenH - 30 - config.panelHeight
    local pPosX, pPosY, _ = getElementPosition(localPlayer)
    local _, _, pRotZ = getElementRotation(localPlayer)
    local pDimension = getElementDimension(localPlayer)

    alphaProgress = lerp(alphaProgress, 1, 0.04)
    
    if (pDimension == 0) then
        local blips = getElementsByType('blip')
        local _, _, camRotZ = getElementRotation(getCamera())

        dxUpdateScreenSource(screenSource, true)
        dxSetRenderTarget(renderTarget, true)
        dxSetBlendMode('modulate_add')

        dxDrawRectangle(0, 0, targetSize, targetSize, tocolor(45, 45, 45, (alphaProgress * 255)))
        dxDrawImageSection(0, 0, targetSize, targetSize, remapSecond(pPosX) - targetSize / zoom / 2, remapFirst(pPosY) - targetSize / zoom / 2, targetSize / zoom, targetSize / zoom, map, 0, 0, tocolor(255, 255, 255, (alphaProgress * 255)))

        for i = 1, #blips do
            local v = blips[i]
            if (v) then
                local blipIcon = getBlipIcon(v)
                local blipX, blipY, _ = getElementPosition(v)
                renderBlip(blipIcon, blipX, blipY, pPosX, pPosY, 20, 20, tocolor(255, 255, 255, 255), camRotZ)
            end
        end
        
        dxSetBlendMode('blend')
        dxSetRenderTarget()
        
        dxDrawImage(gPosX - targetSize / 2 + config.panelWidth / 2, gPosY - targetSize / 2 + config.panelHeight / 2, targetSize, targetSize, renderTarget, camRotZ, 0, 0, tocolor(255, 255, 255, (alphaProgress * 255)))
        dxDrawImage(gPosX, gPosY, config.panelWidth, config.panelHeight, 'assets/images/mask.png', 0, 0, 0, tocolor(255, 255, 255, (alphaProgress * 255)))
        splitMask(screenSource, gPosX, gPosY, config.panelWidth, config.panelHeight, targetSize * 0.75)
        dxDrawImage(gPosX + (config.panelWidth - size) / 2, gPosY + (config.panelHeight - size) / 2, size, size, 'assets/images/arrow.png', camRotZ + abs(360 - pRotZ), 0, 0, tocolor(255, 255, 255, (alphaProgress * 255)))
    end
end

function toggleMinimap(bool)
    if (type(bool) ~= 'boolean') then
        return
    end

    if (bool) then
        addEventHandler('onClientRender', root, minimap, false, 'low')
        renderMinimap = true
    else
        removeEventHandler('onClientRender', root, minimap)
        renderMinimap = false
        clearMemory()
    end
end

function clearMemory()
    if (isElement(renderTarget)) then
        destroyElement(renderTarget)
        renderTarget = nil
    end
    if (isElement(map)) then
        destroyElement(map)
        map = nil
    end
end