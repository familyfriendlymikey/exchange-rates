import 'imba/std'

global css

	@root
		#bg:#20222f #fg:#2b6cef

	*
		box-sizing:border-box ff:Open Sans c:#bfdbfe

	body
		bg:#bg ff:Arial inset:0 d:vcc m:0

	.glassy
		bg:#bg/95 backdrop-filter:blur(10px)

tag app

	get render? do mounted?

	get api_key
		imba.locals.api_key

	set api_key val
		imba.locals.api_key = val

	def mount
		api_key ??= global.prompt('Open exchange rates api key') or undefined

		return if fatal

		imba.locals.query ??= ''

		today = (new Date).toISOString!.slice(0,10)

		if !imba.locals[today]
			await fetch-rates!

		render!

	get amount
		imba.locals.query.replaceAll(',','')

	get rates
		imba.locals[today]..rates

	def fetch-rates
		fetching = yes
		let url = "https://openexchangerates.org/api/latest.json?app_id={api_key}"
		let res = await global.fetch(url).then(&.json!)
		imba.locals[today] = res
		fetching = no

	get hits
		if /^[a-zA-Z]+$/.test(imba.locals.query)
			Object.entries(rates).filter do
				$1[0].toLowerCase!.startsWith(imba.locals.query)
		else
			Object.entries(rates).sort do
				imba.locals.pinned..[$1[0]] ? -1 : 1

	def toggle-pin code
		if imba.locals.pinned..[code]
			unpin code
		else
			pin code

	def unpin code
		delete imba.locals.pinned[code]

	def pin code
		imba.locals.pinned ??= {}
		imba.locals.pinned[code] = yes
		imba.locals.pinned = imba.locals.pinned

	def add s
		imba.locals.query += String(s)

	def del
		imba.locals.query = imba.locals.query.slice(0,-1)

	def clear
		imba.locals.query = ''

	get fatal
		!api_key

	<self>
		css d:vts pos:rel s:100%

		if fatal
			<div> "No api key found"

		else

			<.glassy>
				css p:20px pos:abs t:0 w:100%
				<input bind=imba.locals.query>
					css ol:none rd:5px ta:center c:#93c5fd
						bd:2px solid #60a5fa fs:25px px:10px
						w:100% mih:80px
						bg:clear

			<div>
				css d:vts g:20px ofy:auto pt:120px px:20px
				for [code, rate] of hits
					<div .pinned=(imba.locals.pinned..[code])
						key=code
						@touch.if(!imba.locals.pinned..[code]).hold(duration=1s).trap=pin(code)
						@touch.if(imba.locals.pinned..[code]).hold(duration=1s).trap=unpin(code)
					>
						css d:hcs rd:5px py:10px
							bg:white/4
							@.pinned bg:#fg
							> fl:1 d:vcc
						<div>
							<div> "USD to {code}"
							<div> (rates[code] * amount).toFixed(2)
						<div>
							<div> "{code} to USD"
							<div> (amount / rates[code]).toFixed(2)

			<.glassy>
				css pos:abs b:0 w:100% d:vts us:none h:50vh
					bxs:0 0 10px #1f212e
					> d:hcs fl:1
					%btn s:100% d:hcc e:200ms
						@media(hover) @hover bg:white/2
						@.active bg:white/3.5
						@active bg:white/5

				<div>
					<%btn @click=add(1)> 1
					<%btn @click=add(2)> 2
					<%btn @click=add(3)> 3
				<div>
					<%btn @click=add(4)> 4
					<%btn @click=add(5)> 5
					<%btn @click=add(6)> 6
				<div>
					<%btn @click=add(7)> 7
					<%btn @click=add(8)> 8
					<%btn @click=add(9)> 9
				<div>
					<%btn @click=add('.')> '.'
					<%btn @click=add(0)> 0
					<%btn @click=del> 'del'
				<div>
					<%btn @click=clear> 'clear'
						css mih:125px

imba.mount <app>
