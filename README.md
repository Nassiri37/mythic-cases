## Description
This resource lets you create usable crates, that will give the player items that you associate with them.

## Features
* Use local or remote images for spinner
* Create multiple cases, each with the own set of items
* Randomized, server-sided item selection and validation
* Included several CSGO case inventory images, and included crates as an example in the config

## Credit
- [Dimka Zheleznov](https://codepen.io/zheleznov) for the UI code and posting it to codepen. Wherever you are, hats off to you. I absolutely copied near-100% to make this work.
- [JoeSzymkowiczFiveM] (https://github.com/JoeSzymkowiczFiveM) for posting the QBCore verison all I did was convert the script to work for Mythic Framework

## Dependencies
- [MythicFramework](https://github.com/orgs/Mythic-Framework/repositories)

## Preview
https://streamable.com/24639d (Not Updated due to it working the exact same except I added a cancel button)

## In mythic-inventory/items create a new .lua called cases.lua and paste the contents below in there
```lua

   _itemsSource["cases"] = {
      {
		name = "mystery_case",
		label = "Mystery Case",
		description = "Get some cool shit or something",
		price = 0,
		isUsable = true,
		isRemoved = false,
		isStackable = false,
		type = 5,
		rarity = 1,
		closeUi = true,
		metalic = false,
		weight = 0,
	},
    --Optional
    --[[
        {
		name = "case_breakout",
		label = "Breakout Case",
		description = "Get some cool shit or something",
		price = 0,
		isUsable = true,
		isRemoved = false,
		isStackable = false,
		type = 5,
		rarity = 1,
		closeUi = true,
		metalic = false,
		weight = 0,
	},
    {
		name = "case_chroma2",
		label = "Chroma Case 2",
		description = "Get some cool shit or something",
		price = 0,
		isUsable = true,
		isRemoved = false,
		isStackable = false,
		type = 5,
		rarity = 1,
		closeUi = true,
		metalic = false,
		weight = 0,
	},
        {
		name = "case_dangerzone",
		label = "Danger Zone Case",
		description = "Get some cool shit or something",
		price = 0,
		isUsable = true,
		isRemoved = false,
		isStackable = false,
		type = 5,
		rarity = 1,
		closeUi = true,
		metalic = false,
		weight = 0,
	},
        {
		name = "case_falcion",
		label = "Falcion Case",
		description = "Get some cool shit or something",
		price = 0,
		isUsable = true,
		isRemoved = false,
		isStackable = false,
		type = 5,
		rarity = 1,
		closeUi = true,
		metalic = false,
		weight = 0,
	},]]--

}

```


