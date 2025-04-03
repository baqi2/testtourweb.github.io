// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 获取所有标签和页面区域
    const tabs = document.querySelectorAll('.tabs li');
    const sections = document.querySelectorAll('section');
    
    // 点击标签切换页面区域
    tabs.forEach(tab => {
        tab.addEventListener('click', function(e) {
            // 阻止默认行为
            e.preventDefault();
            
            // 获取目标区域的ID
            const targetId = this.querySelector('a').getAttribute('href');
            
            // 平滑滚动到目标区域
            document.querySelector(targetId).scrollIntoView({
                behavior: 'smooth'
            });
        });
    });
    
    // 滚动监听，高亮当前区域对应的标签
    window.addEventListener('scroll', function() {
        let current = '';
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            const scrollPosition = window.pageYOffset;
            const windowHeight = window.innerHeight;
            
            // 使用更精确的计算方法来确定当前区域
            // 当区域的顶部进入视口的1/3位置，或者区域占据了大部分视口时，将其ID设为当前区域
            if (
                (scrollPosition >= (sectionTop - windowHeight/3)) && 
                (scrollPosition < (sectionTop + sectionHeight))
            ) {
                current = section.getAttribute('id');
            }
        });
        
        // 更新活动标签
        tabs.forEach(tab => {
            tab.classList.remove('active');
            const targetId = tab.querySelector('a').getAttribute('href').substring(1);
            
            // 处理合并后的标签页逻辑
            if (targetId === 'home' && current === 'home') {
                tab.classList.add('active');
            } else if (targetId === 'projects' && (current === 'projects' || current === 'features' || current === 'destinations')) {
                tab.classList.add('active');
            } else if (targetId === 'testimonials' && current === 'testimonials') {
                tab.classList.add('active');
            } else if (targetId === 'contact' && current === 'contact') {
                tab.classList.add('active');
            } else if (targetId === current) {
                tab.classList.add('active');
            }
        });
        
        // 添加额外的检查，确保testimonials和contact部分能被正确检测
        // 这是为了解决这两个部分的滚动监听问题
        const testimonials = document.getElementById('testimonials');
        const contact = document.getElementById('contact');
        // 使用已经定义的scrollPosition和windowHeight变量，避免重复定义
        const bottomThreshold = 100; // 底部阈值
        
        // 检查是否接近页面底部，如果是，则激活contact标签
        if (scrollPosition + windowHeight >= document.body.offsetHeight - bottomThreshold) {
            tabs.forEach(tab => {
                const targetId = tab.querySelector('a').getAttribute('href').substring(1);
                if (targetId === 'contact') {
                    tabs.forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                }
            });
        }
        // 特别检查testimonials部分
        else if (testimonials && contact) {
            const testimonialsTop = testimonials.offsetTop;
            const testimonialsBottom = testimonialsTop + testimonials.clientHeight;
            const contactTop = contact.offsetTop;
            
            // 如果在testimonials和contact之间，确保testimonials标签被激活
            if (scrollPosition >= testimonialsTop && scrollPosition < contactTop) {
                tabs.forEach(tab => {
                    const targetId = tab.querySelector('a').getAttribute('href').substring(1);
                    if (targetId === 'testimonials') {
                        tabs.forEach(t => t.classList.remove('active'));
                        tab.classList.add('active');
                    }
                });
            }
        }
    });
}); // 修复了多余的右括号
