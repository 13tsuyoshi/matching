function deferred_acceptance(m_prefs::Matrix{Int},
                             f_prefs::Matrix{Int},
    caps::Vector{Int})

    m_prefs = m_prefs'
    f_prefs = f_prefs'    
    m_size = size(m_prefs, 1)#男の数
    f_size = size(f_prefs, 1)#女の数
    is_single_prop = ones(Bool,m_size)#男たちが独身かどうか。０なら独身でない１なら独身
    next_resp = ones(Int,m_size)#各人の男たちにとって次求婚する女の順位（最初は皆一番好きな女からアッタクしていく）
    current_prop = zeros(Int,sum(caps))#暫定的にマッチングしてる女各人にとっての男たちのリスト。m_sizeでいいよね？

    indptr = Array(Int, f_size+1)
    indptr[1] = 1
    for i in 1:f_size
        indptr[i+1] = indptr[i] + caps[i]
    end

    caps_cnt=copy(caps)

    while sum(is_single_prop)　!= 0
         for m in 1:m_size#男の数分全員考える
                    if is_single_prop[m]#もしmが独身なら（１なら）
                        f = m_prefs[m, next_resp[m]]  # 次求婚する女に求婚する
                        if f == 0# 次求婚する女がマッチングしなかった時の状態の女だったらつまり誰とも結婚したくなかったら
                        is_single_prop[m] = false#独身とみなさない #Falseではダメ
                        elseif caps_cnt[f] >= 1#capscnt[f]にまだ空きがあれば
                            if (find(f_prefs[f,:].==m) .< find(f_prefs[f,:].==0)) == trues(1)#fに取ってmが今の彼氏よりもよかったら
                                now_f = sum(caps[1:f]) +1 - caps_cnt[f] #前から順に入れていく。
                                current_prop[now_f] = m　#mに仮マッチさせる
                                is_single_prop[m] = false#mを独身でなくさせる
                                caps_cnt[f] -=  1 #caps_cnt[f] の空き容量を一つなくす
                            end
                        elseif  caps_cnt[f] ==0#capscnt[f]がいっぱいだったら
                            pooled = current_prop[indptr[f]:indptr[f+1]-1]#ここ注意。indptrの定義による#fについて仮マッチングしている男たちをリストアップし
                            a= 0
                            worst = 0
                            worst_psn=0    
                            for i in pooled #fと仮マッチングしている奴らの選好順位をリストアップしその中の一番低い選好のやつを洗い出しておく。
                                if (find(f_prefs[f,:].==i) .> a)== trues(1)
                                    worst  = find(f_prefs[f,:].==i)#一番低い選好
                                    worst_psn= i#一番低い選好の該当者
                                    a= find(f_prefs[f,:].==i)
                                end
                            end
                            if (find(f_prefs[f,:].==m) .< worst) == trues(1)#一番低い選好と比べ、自分がそれよりも良い選好なら
                                is_single_prop[worst_psn]= true#一番低いやつが独身状態となる
                                current_prop[find(current_prop.==worst_psn)] = m　#mを一番低いやつが属していたところでマッチさせる#もっと簡単にできないだろうか              
                                is_single_prop[m] = false#mを独身でなくさせる
                            end
                        end
                    next_resp[m] += 1#次の求婚対象の女を次の順位の女にする
                    end
            end

    end
    m_matched = Array(Int64,m_size)
        for m in 1:m_size
            m_matched[m]= m_prefs[m,next_resp[m]-1]
        end
    f_matched = current_prop

    return m_matched, f_matched, indptr
end

function deferred_acceptance(m_prefs::Matrix{Int}, f_prefs::Matrix{Int})
    caps = ones(Int, size(f_prefs, 2))
    m_matched, f_matched, indptr =
    deferred_acceptance(m_prefs, f_prefs, caps)
    return m_matched, f_matched
end