infinity = 1 / 0

exports class DefaultRuleSet
  apPerTurn: 20

  terrainCosts:
    base:
      default: infinity
    deepwater:
      default: infinity
      naval: 3
    desert:
      default: 4
      naval: infinity
    factory:
      default: 2
      naval: infinity
    forrest:
      default: 5
      light: 2
      naval: infinity
    mountain:
      default: infinity
      naval: infinity
      infantry: 6
    plain:
      default: 2
      naval: infinity
    shallowwater:
      default: infinity
      naval: 5
    road:
      naval: infinity
      default: 1

  bulletSpecs:
    default:
      accuracy: 0.8
      damage:
        min: 3
        max: 5
      criticial: 0.1
      modifiers: {}
    artilleryShell:
      accuracy: 0.6
      damage:
        min: 5
        max: 10
      criticial: 0.05
      modifiers:
        heavy: 2.3


  unitSpecs:
    heavytank:
      costs:
        create: 12
        fire: 1
      hp: 20
      mp: 3
      attackRange:
        min: 1
        max: 3
      bullets: -> ['default']
      tags: ['land', 'heavy']
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Heavy Tank"
        description: "Heavy Tank Yay"
        weakVs: 'weak weak'
        strongVs: 'strong strong'
    lighttank:
      costs:
        create: 5
        fire: 1
      hp: 8
      mp: 7
      attackRange:
        min: 1
        max: 3
      bullets: -> ['default']
      tags: ['land', 'light']
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Light Tank"
        description: "Light Tank Yay"
        weakVs: 'weak weak'
        strongVs: 'strong strong'
    mediumartillery:
      costs:
        create: 14
        fire: 1
      hp: 8
      mp: 3
      attackRange:
        min: 2
        max: 5
      bullets: -> ['artilleryShell']
      tags: ['land', 'medium', 'artillery']
      returnsFire: false
      movesAndFires: false
      labels:
        name: "Medium Artillery"
        description: "Medium Artillery"
        weakVs: 'weak weak'
        strongVs: 'strong strong'
    mediumtank:
      costs:
        create: 8
        fire: 1
      hp: 10
      mp: 5
      attackRange:
        min: 1
        max: 3
      bullets: -> ['default']
      tags: ['land', 'medium']
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Medium Tank"
        description: "Medium Tank Yay"
        weakVs: 'weak weak'
        strongVs: 'strong strong'
    spiderbot:
      costs:
        create: 5
        fire: 1
      hp: 10
      mp: 8
      attackRange:
        min: 1
        max: 1
      bullets: -> ['default']
      tags: ['land', 'light']
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Spider Bot"
        description: "Spider Bot Yay"
        weakVs: 'weak weak'
        strongVs: 'strong strong'
