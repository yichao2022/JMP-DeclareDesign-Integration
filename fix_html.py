import re

with open('/Users/cary/.openclaw/workspace/JMP-DeclareDesign-Integration/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern: <span class="header-section-number">X</span> X. 
# or <span class="header-section-number">X.Y</span> X.Y 
pattern = r'<span class="header-section-number">([0-9\.]+)</span>\s+\1\.?\s*'
replacement = r'<span class="header-section-number">\1</span> '

new_content = re.sub(pattern, replacement, content)

with open('/Users/cary/.openclaw/workspace/JMP-DeclareDesign-Integration/index.html', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Fixed HTML.")
