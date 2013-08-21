class Bullet
  constructor: ({@game, @type}) ->
    @specs = @game.ruleSet.bulletSpecs[@type]

  fireAt: (enemy) ->
    if @hit = Math.random() <= @specs.accuracy
      damageRange = @specs.damage.max - @specs.damage.min
      @damage = @specs.damage.min + Math.random() * damageRange

      damageModifier = 1
      for type, modifier of @specs.modifiers
        damageModifier = modifier if enemy.isTagged(type) and modifier > damageModifier

      @damage *= damageModifier

      if @criticalStrike = Math.random() < @specs.critical
        @damage *= 2

      @damage = Math.floor(@damage)

    @hit

exports 'Bullet', Bullet