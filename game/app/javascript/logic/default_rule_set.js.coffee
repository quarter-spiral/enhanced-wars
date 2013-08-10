infinity = 1 / 0

exports class DefaultRuleSet
  apPerTurn: 20
  pointsForWin: 40
  rewards:
    captureDropZone: 4
    attack: 1
    streak: (streak) ->
      switch streak
        when 0
          0
        when 1
          1
        when 2
          3
        else
          5

  terrainCosts:
    base:
      default: infinity

    deepwater:
      default: infinity
      naval: 3

    desert:
      default: 5
      naval: infinity

    factory:
      default: 2
      naval: infinity

    forrest:
      default: 4

      #light: 2,
      naval: infinity

    pineforrest:
      default: 4

      #light: 2,
      naval: infinity

    mountain:
      default: 6
      naval: infinity


    #infantry: 6
    plain:
      default: 3
      naval: infinity

    shallowwater:
      default: infinity
      naval: 5

    road:
      naval: infinity
      default: 2

  bulletSpecs:
    default:
      accuracy: 0.95
      damage:
        min: 2
        max: 4

      critical: 0.05
      modifiers:
        light: 0.8
        heavy: .4

    artilleryShell:
      accuracy: 0.6
      damage:
        min: 5
        max: 10

      critical: 0.05
      modifiers:
        heavy: 2.3

  unitSpecs:
    heavytank:
      costs:
        create: 12
        fire: 1
        move: 1

      hp: 20
      mp: 8
      attackRange:
        min: 1
        max: 1

      bullets: ->
        ["default", "default", "default", "default"]

      tags: ["land", "heavy"]
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Big Boy"
        description: "Heavy Tank Yay"
        weakVs: "weak weak"
        strongVs: "strong strong"

    lighttank:
      costs:
        create: 5
        fire: 1
        move: 1

      hp: 10
      mp: 15
      attackRange:
        min: 1
        max: 1

      bullets: ->
        ["default", "default"]

      tags: ["land", "light"]
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Raider"
        description: "Fast first striker"
        weakVs: "weak weak"
        strongVs: "strong strong"

    mediumartillery:
      costs:
        create: 16
        fire: 2
        move: 1

      hp: 7
      mp: 6
      attackRange:
        min: 2
        max: 3

      bullets: ->
        ["default","default","default"]

      tags: ["land", "light", "artillery"]
      returnsFire: false
      movesAndFires: false
      labels:
        name: "Spear Chucker"
        description: "Medium Artillery"
        weakVs: "weak weak"
        strongVs: "strong strong"

    mediumtank:
      costs:
        create: 8
        fire: 1
        move: 1

      hp: 12
      mp: 10
      attackRange:
        min: 1
        max: 1

      bullets: ->
        ["default", "default", "default"]

      tags: ["land", "medium"]
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Work Horse"
        description: "Medium Tank Yay"
        weakVs: "weak weak"
        strongVs: "strong strong"

    spiderbot:
      costs:
        create: 25
        fire: 1
        move: 1

      hp: 7
      mp: 15
      attackRange:
        min: 1
        max: 1

      bullets: ->
        ["default"]

      tags: ["land", "light"]
      returnsFire: true
      movesAndFires: true
      labels:
        name: "Spider bomb"
        description: "Spider Bot Yay"
        weakVs: "weak weak"
        strongVs: "strong strong"
