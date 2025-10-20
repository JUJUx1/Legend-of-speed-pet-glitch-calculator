document.addEventListener('DOMContentLoaded', function() {
    const rebirthInput = document.getElementById('rebirth');
    const raritySelect = document.getElementById('rarity');
    const currentLevelInput = document.getElementById('current-level');
    const currentExpInput = document.getElementById('current-exp');
    const calculateBtn = document.getElementById('calculate-btn');
    const orbExpValue = document.getElementById('orb-exp-value');
    const levelsCount = document.getElementById('levels-count');
    const resultsContainer = document.getElementById('results-container');

    const chartRaritySelect = document.getElementById('chart-rarity');
    const minRebirthChartInput = document.getElementById('min-rebirth-chart');
    const maxRebirthChartInput = document.getElementById('max-rebirth-chart');
    const generateChartBtn = document.getElementById('generate-chart-btn');
    const exportChartBtn = document.getElementById('export-chart-btn');
    const exportTxtBtn = document.getElementById('export-txt-btn');
    const chartCanvas = document.getElementById('glitch-chart');
    const chartLegend = document.getElementById('chart-legend');

    let glitchChart = null;

    function generateCumulativeExpTable(baseExp){
        const table=[];
        let cum=0;
        for(let i=1;i<=50;i++){cum+=baseExp*i; table.push(cum);}
        return table;
    }

    const petExpTables={
        'OMEGA':generateCumulativeExpTable(10000),
        'UNIQUE':generateCumulativeExpTable(5000),
        'EPIC':generateCumulativeExpTable(4000),
        'RARE':generateCumulativeExpTable(3000),
        'ADVANCE':generateCumulativeExpTable(2000),
        'BASIC':generateCumulativeExpTable(1000)
    };

    function updateOrbExp(){
        const orbExp=15*((parseInt(rebirthInput.value)||0)+1);
        orbExpValue.textContent=orbExp;
    }

    function calculateGlitchableLevels(){
        const rebirth=parseInt(rebirthInput.value)||0;
        const rarity=raritySelect.value;
        const currentLevel=parseInt(currentLevelInput.value)||1;
        const currentExp=parseInt(currentExpInput.value)||0;

        if(currentLevel<1||currentLevel>50){alert('Current level must be 1-50'); return;}
        const orbExp=15*(rebirth+1);
        const table=petExpTables[rarity];
        let currExp=(currentLevel>1?table[currentLevel-2]:0)+currentExp;
        const glitchLevels=[];
        for(let lvl=currentLevel;lvl<=50;lvl++){
            const rem=table[lvl-1]-currExp;
            if(rem>0 && rem%orbExp===0){
                glitchLevels.push({level:lvl, expNeeded:rem, orbsNeeded:rem/orbExp});
            }
        }
        displayResults(glitchLevels,orbExp);
    }

    function displayResults(levels,orbExp){
        orbExpValue.textContent=orbExp;
        levelsCount.textContent=levels.length;
        resultsContainer.innerHTML='';
        if(levels.length===0){
            resultsContainer.innerHTML='<div class="no-results">No glitchable levels found</div>'; 
            return;
        }
        levels.forEach(item=>{
            const div=document.createElement('div');
            div.className='result-item';
            div.innerHTML=`<div class="result-header"><span class="level">Level ${item.level}</span><span class="exp-needed">EXP: ${item.expNeeded.toLocaleString()}</span></div><div class="orbs-needed">Orbs Needed: ${item.orbsNeeded}</div>`;
            resultsContainer.appendChild(div);
        });
    }

    function generateChart(){
        const rarity = chartRaritySelect.value;
        const minR = parseInt(minRebirthChartInput.value) || 0;
        const maxR = parseInt(maxRebirthChartInput.value) || 20;
        const table = petExpTables[rarity];
        const chartData = [];

        for(let r = minR; r <= maxR; r++){
            let firstLevel = null;
            for(let lvl=1; lvl<=50; lvl++){
                const orbExp = 15*(r+1);
                const rem = table[lvl-1];
                if(rem % orbExp === 0){
                    firstLevel = lvl;
                    break;
                }
            }
            if(firstLevel) chartData.push({x: r, y: firstLevel});
        }

        if(glitchChart) glitchChart.destroy();
        const ctx = chartCanvas.getContext('2d');

        glitchChart = new Chart(ctx, {
            type: 'scatter',
            data: {
                datasets: [{
                    label: 'First Glitch Level',
                    data: chartData,
                    backgroundColor: '#fdbb2d',
                    borderColor: '#b21f1f',
                    pointRadius: 8
                }]
            },
            options: {
                responsive:true,
                maintainAspectRatio:false,
                scales: {
                    x: {
                        type: 'linear',
                        title: {display:true,text:'Rebirth',color:'#fdbb2d', font:{size:16,weight:'bold'}},
                        ticks: {stepSize:1, color:'#ddd'},
                        min: minR,
                        max: maxR,
                        grid:{color:'rgba(255,255,255,0.1)'}
                    },
                    y: {
                        title:{display:true,text:'Pet Level',color:'#fdbb2d', font:{size:16,weight:'bold'}},
                        ticks:{color:'#ddd', stepSize:5},
                        min: 1,
                        max: 50,
                        reverse: true,
                        grid:{color:'rgba(255,255,255,0.1)'}
                    }
                },
                plugins: {
                    legend:{display:false},
                    tooltip: {
                        callbacks: {
                            label: function(ctx){
                                return `Level ${ctx.raw.y} at Rebirth ${ctx.raw.x}`;
                            }
                        }
                    }
                }
            }
        });

        chartLegend.innerHTML='';
        const item=document.createElement('div'); 
        item.className='legend-item';
        const colorBox=document.createElement('div'); 
        colorBox.className='legend-color'; 
        colorBox.style.backgroundColor='#fdbb2d';
        const label=document.createElement('span'); 
        label.textContent='First Glitch Level';
        item.appendChild(colorBox); 
        item.appendChild(label); 
        chartLegend.appendChild(item);
    }

    function exportTxt(){
        const rarity = chartRaritySelect.value;
        const minR = parseInt(minRebirthChartInput.value) || 0;
        const maxR = parseInt(maxRebirthChartInput.value) || 20;
        const table = petExpTables[rarity];
        let txt=`Legend of Speed Pet Glitchable Levels - ${rarity}\n\n`;
        txt += `Rebirth | First Glitch Level\n`;
        txt += `--------|-----------------\n`;

        for(let r = minR; r <= maxR; r++){
            let firstLevel = 'None';
            for(let lvl=1; lvl<=50; lvl++){
                const orbExp = 15*(r+1);
                const rem = table[lvl-1];
                if(rem % orbExp === 0){
                    firstLevel = lvl;
                    break;
                }
            }
            txt += `${r}       | ${firstLevel}\n`;
        }

        const blob = new Blob([txt], {type:'text/plain'});
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'glitchable_levels.txt';
        link.click();
    }

    // Events
    updateOrbExp();
    calculateBtn.addEventListener('click',calculateGlitchableLevels);
    rebirthInput.addEventListener('input',updateOrbExp);
    generateChartBtn.addEventListener('click',generateChart);
    exportChartBtn.addEventListener('click',()=>{
        if(glitchChart){ 
            const link = document.createElement('a'); 
            link.href = glitchChart.toBase64Image(); 
            link.download = 'glitch-chart.png'; 
            link.click(); 
        }
    });
    exportTxtBtn.addEventListener('click',exportTxt);

    generateChart();
});
