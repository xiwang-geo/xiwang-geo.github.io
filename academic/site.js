(async()=>{
 const content=await fetch('academic/content.json').then(r=>{if(!r.ok)throw Error('Content unavailable');return r.json()});
 const params=new URLSearchParams(location.search);let stored='';try{stored=localStorage.getItem('xw-academic-language')||''}catch{}
 let lang=['zh','en'].includes(params.get('lang'))?params.get('lang'):['zh','en'].includes(stored)?stored:'zh';
 function render(){const d=content[lang];document.documentElement.lang=lang==='zh'?'zh-CN':'en';document.title=location.pathname.includes('research.html')?d.researchPageTitle+' | Xi Wang':d.title;document.querySelector('meta[name=description]').content=d.description;
 document.querySelectorAll('[data-text]').forEach(e=>{if(d[e.dataset.text]!==undefined)e.textContent=d[e.dataset.text]});
 document.querySelectorAll('[data-alt]').forEach(e=>e.alt=d[e.dataset.alt]);document.querySelectorAll('[data-aria]').forEach(e=>e.setAttribute('aria-label',d[e.dataset.aria]));
 document.querySelectorAll('[data-list],[data-flow],[data-steps]').forEach(e=>{const key=e.dataset.list||e.dataset.flow||e.dataset.steps;const tag=e.dataset.steps?'li':'span';e.replaceChildren(...d[key].map(s=>{const x=document.createElement(tag);x.textContent=s;return x}))});
 document.querySelectorAll('[data-case]').forEach(e=>e.href='case-'+e.dataset.case+(lang==='en'?'-en':'')+'.html');
 document.querySelectorAll('[data-destination]').forEach(e=>{let [p,hash]=e.dataset.destination.split('#');e.href=p+'?lang='+lang+(hash?'#'+hash:'')});
 document.querySelectorAll('[data-home-link]').forEach(e=>e.href='index.html?lang='+lang);document.querySelectorAll('[data-cv]').forEach(e=>e.href='academic/cv-'+lang+'.pdf');
 const b=document.querySelector('.language-switch');if(b){b.textContent=lang==='zh'?'EN':'中文';b.setAttribute('aria-label',lang==='zh'?'Switch to English':'切换为中文')}
 document.querySelectorAll('nav a[href*="index.html"]').forEach(e=>{const u=new URL(e.href);u.searchParams.set('lang',lang);e.href=u});
 }
 document.querySelector('.language-switch')?.addEventListener('click',()=>{lang=lang==='zh'?'en':'zh';try{localStorage.setItem('xw-academic-language',lang)}catch{}const u=new URL(location);u.searchParams.set('lang',lang);history.replaceState(null,'',u);render()});
 const menu=document.querySelector('.menu-toggle'),nav=document.querySelector('#navigation');menu?.addEventListener('click',()=>{const opened=nav.classList.toggle('open');menu.setAttribute('aria-expanded',String(opened));menu.textContent=opened?'×':'☰'});nav?.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{nav.classList.remove('open');menu.setAttribute('aria-expanded','false');menu.textContent='☰'}));document.addEventListener('keydown',e=>{if(e.key==='Escape'){nav?.classList.remove('open');menu?.setAttribute('aria-expanded','false');if(menu)menu.textContent='☰'}});
 render();document.documentElement.dataset.ready='true';
})().catch(e=>{console.error(e);document.documentElement.dataset.ready='failed'});
